"""End-to-end API test with a FAKE ML pipeline (no ONNX files needed)."""
import cv2
import numpy as np
import pytest
from fastapi.testclient import TestClient

from app.ml.pipeline import FaceAnalysis
from app.ml.detector import Detection
from app.utils.similarity import l2_normalize

PEOPLE = {p: l2_normalize(np.random.default_rng(p).normal(size=512).astype(np.float32)) for p in (1, 2)}


class FakePipeline:
    """Image pixel [0,0,0] = person id; pixel [0,0,1] = sample noise seed. 99 = spoof, 0 = no face."""
    def analyze(self, img):
        pid, seed = int(img[0, 0, 0]), int(img[0, 0, 1])
        if pid == 0:
            return FaceAnalysis(False, "no_face_detected")
        det = Detection(np.array([10, 10, 200, 200], dtype=np.float32), 0.95, np.zeros((5, 2)))
        if pid == 99:
            return FaceAnalysis(False, "spoof_detected", 1, det, {}, {"label": "Fake", "score": 0.02, "is_live": False})
        noise = np.random.default_rng(1000 + seed).normal(size=512).astype(np.float32)
        emb = l2_normalize(PEOPLE[pid] + 0.03 * noise)
        return FaceAnalysis(True, None, 1, det, {"blur_score": 50.0, "face_width": 190},
                            {"label": "Real", "score": 0.99, "is_live": True}, emb)


class FakeManager:
    def __init__(self, settings): self.pipeline = None
    def load_all(self): self.pipeline = FakePipeline()
    def health(self): return {"loaded": True, "fake": True}


def jpg(pid, seed=0):
    img = np.zeros((64, 64, 3), dtype=np.uint8)
    img[0, 0] = (pid, seed, 0)
    img[10:50, 10:50] = 200
    ok, buf = cv2.imencode(".png", img)  # PNG = lossless so pixel markers survive
    return buf.tobytes()


@pytest.fixture(scope="module")
def client():
    import app.main as main
    main.ModelManager = FakeManager
    with TestClient(main.app) as c:
        yield c


def enroll(client, code, name, pid, office="KADAP"):
    sid = client.post("/api/enrollment/start", json={"employee_code": code, "name": name, "office_code": office}).json()["session_id"]
    for seed in range(5):
        r = client.post("/api/enrollment/sample", data={"session_id": sid}, files={"file": ("a.png", jpg(pid, seed), "image/png")}).json()
        assert r["accepted"], r
    return client.post("/api/enrollment/complete", json={"session_id": sid})


def test_full_flow(client):
    assert client.get("/health").json()["status"] == "ok"
    assert enroll(client, "123", "Karthikeya", 1).json()["enrolled"] is True
    assert enroll(client, "124", "Santhoshi", 2, "TIRUPATI").json()["enrolled"] is True

    r = client.post("/api/face/recognize", files={"file": ("a.png", jpg(1, 50), "image/png")}).json()
    assert r["recognized"] and r["employee"]["employee_code"] == "123"
    assert r["attendance"]["action"] == "CHECK_IN"

    r2 = client.post("/api/face/recognize", files={"file": ("a.png", jpg(1, 51), "image/png")}).json()
    assert r2["attendance"]["action"] == "ALREADY_CHECKED_IN"   # cooldown, one row per day

    assert client.post("/api/attendance/check-out", json={"employee_code": "123"}).json()["action"] == "CHECK_OUT"
    today = client.get("/api/attendance/today").json()
    assert len(today) == 1 and today[0]["check_out"] is not None


def test_spoof_and_no_face(client):
    r = client.post("/api/face/recognize", files={"file": ("a.png", jpg(99), "image/png")}).json()
    assert not r["recognized"] and r["reason"] == "spoof_detected"
    r = client.post("/api/face/recognize", files={"file": ("a.png", jpg(0), "image/png")}).json()
    assert r["reason"] == "no_face_detected"


def test_rejected_frames_dont_count_and_duplicates_rejected(client):
    sid = client.post("/api/enrollment/start", json={"employee_code": "200", "name": "X", "office_code": "KADAP"}).json()["session_id"]
    f = lambda b: {"file": ("a.png", b, "image/png")}
    assert not client.post("/api/enrollment/sample", data={"session_id": sid}, files=f(jpg(0))).json()["accepted"]
    r = client.post("/api/enrollment/sample", data={"session_id": sid}, files=f(jpg(1, 7))).json()
    assert r["accepted"] and r["captured"] == 1
    d = client.post("/api/enrollment/sample", data={"session_id": sid}, files=f(jpg(1, 7))).json()  # identical frame
    assert d["reason"] == "duplicate_frame" and d["captured"] == 1
    assert client.post("/api/enrollment/complete", json={"session_id": sid}).status_code == 422


def test_same_face_under_new_code_is_blocked(client):
    r = enroll(client, "999", "Clone", 1)
    assert r.status_code == 409 and r.json()["detail"]["error"] == "too_similar_to_existing_employee"


def test_reenroll_keeps_data_and_delete(client):
    assert enroll(client, "123", "Karthikeya R", 1).json()["enrolled"] is True
    assert client.get("/api/employees/123").json()["embedding_count"] == 5
    assert client.delete("/api/employees/124").json()["deactivated"] is True
    r = client.post("/api/face/recognize", files={"file": ("a.png", jpg(2, 60), "image/png")}).json()
    assert not (r["recognized"] and r["employee"]["employee_code"] == "124")
    assert client.get("/api/admin/dashboard").json()["total_employees"] == 1
