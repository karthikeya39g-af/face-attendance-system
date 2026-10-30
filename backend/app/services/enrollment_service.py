import threading
import time
import uuid
from dataclasses import dataclass, field

import numpy as np
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.ml.matcher import GalleryMatcher
from app.ml.model_manager import ModelManager
from app.repositories.attendance_repository import EventRepository
from app.repositories.embedding_repository import EmbeddingRepository
from app.repositories.employee_repository import EmployeeRepository, OfficeRepository
from app.utils.image import decode_image
from app.utils.similarity import l2_normalize


class EnrollmentError(Exception):
    def __init__(self, code: str, status: int = 400, detail: dict | None = None):
        self.code, self.status, self.detail = code, status, detail or {}


@dataclass
class EnrollmentSession:
    session_id: str
    employee_code: str
    name: str
    office_code: str
    expires_at: float
    samples: list[dict] = field(default_factory=list)  # {embedding, blur_score, liveness_score}


class EnrollmentService:
    def __init__(self, models: ModelManager, matcher: GalleryMatcher, settings: Settings):
        self.models, self.matcher, self.s = models, matcher, settings
        self._sessions: dict[str, EnrollmentSession] = {}
        self._lock = threading.Lock()

    # ----- session helpers -----
    def _purge(self) -> None:
        now = time.time()
        for sid in [k for k, v in self._sessions.items() if v.expires_at < now]:
            self._sessions.pop(sid, None)

    def _get(self, sid: str) -> EnrollmentSession:
        with self._lock:
            self._purge()
            sess = self._sessions.get(sid)
        if not sess:
            raise EnrollmentError("session_not_found_or_expired", 404)
        return sess

    # ----- API operations -----
    def start(self, db: Session, employee_code: str, name: str, office_code: str) -> dict:
        if not OfficeRepository(db).by_code(office_code):
            raise EnrollmentError("unknown_office", 422)
        sess = EnrollmentSession(
            session_id=uuid.uuid4().hex, employee_code=employee_code.strip(), name=name.strip(),
            office_code=office_code, expires_at=time.time() + self.s.ENROLLMENT_TTL_SECONDS)
        with self._lock:
            self._purge()
            self._sessions[sess.session_id] = sess
        return {"session_id": sess.session_id, "target": self.s.ENROLLMENT_TARGET,
                "expires_in_seconds": self.s.ENROLLMENT_TTL_SECONDS}

    def add_sample(self, session_id: str, data: bytes) -> dict:
        sess = self._get(session_id)
        target = self.s.ENROLLMENT_TARGET
        base = {"captured": len(sess.samples), "target": target}
        if len(sess.samples) >= target:
            return {**base, "accepted": False, "reason": "target_already_reached"}

        img = decode_image(data, self.s.MAX_IMAGE_SIDE)
        a = self.models.pipeline.analyze(img)
        if not a.ok:  # rejected frame != failed enrollment: counter does NOT move
            return {**base, "accepted": False, "reason": a.reason, "quality": a.quality or None,
                    "liveness": ({"label": a.liveness["label"], "score": a.liveness["score"]} if a.liveness else None)}

        emb = a.embedding
        consistency = None
        if sess.samples:
            mat = np.vstack([x["embedding"] for x in sess.samples])
            sims = mat @ emb
            if float(sims.max()) >= self.s.DUPLICATE_SIMILARITY:
                return {**base, "accepted": False, "reason": "duplicate_frame", "quality": a.quality}
            consistency = float(l2_normalize(mat.mean(axis=0)) @ emb)
            if len(sess.samples) >= 3 and consistency < self.s.MIN_CENTROID_SIMILARITY:  # trust centroid from 3 samples
                return {**base, "accepted": False, "reason": "different_person_or_pose_outlier",
                        "centroid_similarity": round(consistency, 4), "quality": a.quality}

        with self._lock:
            sess.samples.append({"embedding": emb, "blur_score": a.quality.get("blur_score"),
                                 "liveness_score": a.liveness["score"]})
            n = len(sess.samples)
        return {"accepted": True, "captured": n, "target": target, "quality": a.quality,
                "consistency": round(consistency, 3) if consistency is not None else None,
                "liveness": {"label": a.liveness["label"], "score": a.liveness["score"]}, "ready": n >= target}

    def complete(self, db: Session, session_id: str) -> dict:
        sess = self._get(session_id)
        if len(sess.samples) < self.s.ENROLLMENT_TARGET:
            raise EnrollmentError("not_enough_samples", 422,
                                  {"captured": len(sess.samples), "target": self.s.ENROLLMENT_TARGET})
        mat = np.vstack([x["embedding"] for x in sess.samples])
        centroid = l2_normalize(mat.mean(axis=0))
        csims = mat @ centroid
        if float(csims.min()) < self.s.MIN_CENTROID_SIMILARITY:
            raise EnrollmentError("inconsistent_samples", 422,
                                  {"min_centroid_similarity": round(float(csims.min()), 4)})
        # identity-contamination guard (the 123-vs-125 problem)
        cross, who = self.matcher.max_similarity_to_others(mat, sess.employee_code)
        if who and cross >= self.s.ENROLL_MAX_CROSS_SIMILARITY:
            raise EnrollmentError("too_similar_to_existing_employee", 409,
                                  {"employee_code": who, "similarity": round(cross, 4)})

        emp_repo = EmployeeRepository(db)
        try:
            office = OfficeRepository(db).by_code(sess.office_code)
            emp = emp_repo.by_code(sess.employee_code)
            if emp is None:
                emp = emp_repo.create(sess.employee_code, sess.name, office.id)
            else:
                emp.name, emp.office_id, emp.is_active = sess.name, office.id, True
            # old embeddings are only removed here, inside the same transaction as the insert
            EmbeddingRepository(db).replace_for_employee(emp.id, sess.samples)
            EventRepository(db).add("ENROLLMENT_COMPLETED", emp.id, office.id,
                                    details={"samples": len(sess.samples)})
            db.commit()
        except Exception:
            db.rollback()  # old embeddings stay intact
            raise
        self.reload_gallery(db)
        with self._lock:
            self._sessions.pop(session_id, None)
        return {"enrolled": True, "employee_code": emp.employee_code, "name": emp.name,
                "samples_saved": len(sess.samples)}

    def cancel(self, session_id: str) -> bool:
        with self._lock:
            return self._sessions.pop(session_id, None) is not None

    def reload_gallery(self, db: Session) -> None:
        self.matcher.set_gallery(EmbeddingRepository(db).load_gallery())
