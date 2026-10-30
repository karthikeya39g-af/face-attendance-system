"""Webcam client for the Face Attendance API (no frontend needed).

  python -m scripts.webcam_client --preview enroll --code 123 --name "Karthikeya" --office KADAP
  python -m scripts.webcam_client --preview recognize

Global options (put them BEFORE enroll/recognize):
  --preview             show a live camera window with status text (needs opencv-python, not headless)
  --camera 0            webcam index (see: ls /dev/video*)
  --source PATH         video file or folder of images instead of the webcam
  --api URL             default http://localhost:8000
  --api-key KEY         if API_KEY is set in .env
  --interval 0.5        seconds between frames sent to the server
Press q or Esc in the preview window to stop.
"""
import argparse
import sys
import threading
import time
from pathlib import Path

import cv2
import httpx

POSES = [
    "look straight at the camera", "turn head slightly LEFT", "turn head slightly RIGHT",
    "tilt chin slightly UP", "tilt chin slightly DOWN", "small smile", "neutral face",
    "move a little closer", "move a little back", "look straight again",
    "turn slightly LEFT again", "turn slightly RIGHT again", "relax, look straight",
    "slight smile, straight", "last one - look straight",
]
HINTS = {
    "no_face_detected": "no face found - face the camera",
    "face_too_small": "move closer to the camera",
    "face_area_too_small": "move closer to the camera",
    "image_too_blurry": "hold still / add light",
    "multiple_faces": "only one person in view",
    "spoof_detected": "liveness says FAKE (real face only)",
    "duplicate_frame": "change your head position a little",
    "different_person_or_pose_outlier": "face the camera more directly",
}
GREEN, RED, YELLOW = (60, 200, 60), (50, 50, 230), (0, 200, 230)


def jpeg(frame) -> bytes:
    ok, buf = cv2.imencode(".jpg", frame, [cv2.IMWRITE_JPEG_QUALITY, 92])
    return buf.tobytes()


def overlay(frame, lines: list[tuple[str, tuple]]):
    """Mirror the image (like a mirror) and draw status text on a dark banner."""
    img = cv2.flip(frame, 1)
    h = 34 * len(lines) + 12
    cv2.rectangle(img, (0, 0), (img.shape[1], h), (0, 0, 0), -1)
    for i, (text, color) in enumerate(lines):
        cv2.putText(img, text, (12, 32 + 34 * i), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color, 2, cv2.LINE_AA)
    return img


def run_loop(args, handle, title: str):
    """Calls handle(frame)->(lines, stop) about every --interval seconds.
    The camera is read continuously so frames are always fresh (no stale buffer);
    the network call runs in a worker thread so the preview never freezes."""
    # ---- file/folder sources: simple, no preview ----
    if args.source and Path(args.source).is_dir():
        for p in sorted(x for x in Path(args.source).iterdir() if x.suffix.lower() in (".jpg", ".jpeg", ".png")):
            img = cv2.imread(str(p))
            if img is not None and handle(img)[1]:
                return
        return

    cap = cv2.VideoCapture(args.source if args.source else int(args.camera))
    if not args.source and cap.isOpened():
        cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc(*"MJPG"))
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, args.width)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, args.height)
        print(f"Camera resolution: {int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))}x{int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))}")
    if not cap.isOpened():
        sys.exit("Cannot open camera. Check: ls /dev/video*  (video0 is normally the real one), "
                 "and close any other app using it.")
    if args.preview:
        try:
            cv2.namedWindow(title)
        except cv2.error:
            sys.exit("--preview needs the GUI build of OpenCV. Run:\n"
                     "  pip uninstall -y opencv-python-headless && pip install opencv-python")

    state = {"frame": None, "lines": [("starting...", YELLOW)], "stop": False}
    lock = threading.Lock()

    def worker():
        while not state["stop"]:
            with lock:
                f = state["frame"]
            if f is None:
                time.sleep(0.05)
                continue
            lines, stop = handle(f.copy())
            with lock:
                state["lines"] = lines
                if stop:
                    state["stop"] = True
            time.sleep(args.interval)

    t = threading.Thread(target=worker, daemon=True)
    t.start()
    try:
        while not state["stop"]:
            ok, frame = cap.read()
            if not ok:
                print("\nStopped: the camera stopped delivering frames (try a lower --width 640 --height 480).")
                break
            with lock:
                state["frame"] = frame
                lines = list(state["lines"])
            if args.preview:
                cv2.imshow(title, overlay(frame, lines))
                if cv2.waitKey(1) & 0xFF in (27, ord("q")):
                    print("\nStopped: q/Esc pressed.")
                    break
            else:
                time.sleep(0.03)
    finally:
        state["stop"] = True
        t.join(timeout=5)
        cap.release()
        if args.preview:
            cv2.destroyAllWindows()


def client(args) -> httpx.Client:
    h = {"X-API-Key": args.api_key} if args.api_key else {}
    return httpx.Client(base_url=args.api, headers=h, timeout=30)


def cmd_enroll(args) -> None:
    with client(args) as c:
        r = c.post("/api/enrollment/start", json={
            "employee_code": args.code, "name": args.name, "office_code": args.office})
        r.raise_for_status()
        sid, target = r.json()["session_id"], r.json()["target"]
        print(f"Enrollment started ({target} samples needed). Look at the camera.\n")
        st = {"done": 0, "tries": 0}

        def handle(frame):
            st["tries"] += 1
            if st["tries"] > args.max_tries:
                print("Too many attempts, stopping.")
                return [("too many attempts", RED)], True
            s = c.post("/api/enrollment/sample", data={"session_id": sid},
                       files={"file": ("f.jpg", jpeg(frame), "image/jpeg")})
            if s.status_code != 200:
                print("API error:", s.text)
                return [("API error", RED)], True
            d = s.json()
            if d["accepted"]:
                st["done"] = d["captured"]
                n = st["done"]
                nxt = POSES[n] if n < len(POSES) and n < target else "done"
                print(f"  OK {n:2d}/{target}  blur={d['quality'].get('blur_score')}  "
                      f"live={d['liveness']['score']}   NEXT: {nxt}")
                if d.get("ready"):
                    return [(f"{n}/{target} DONE - saving...", GREEN)], True
                time.sleep(args.pause)  # time to change pose
                return [(f"OK {n}/{target}", GREEN), (f"NEXT: {nxt}", YELLOW)], False
            reason = d["reason"]
            print(f"  -- rejected: {reason:<32} {HINTS.get(reason, '')}  {d.get('quality') or ''}")
            return [(f"{st['done']}/{target}", GREEN), (HINTS.get(reason, reason), RED)], False

        try:
            run_loop(args, handle, "Enrollment (q = stop)")
        except KeyboardInterrupt:
            pass
        if st["done"] < target:
            c.delete(f"/api/enrollment/cancel/{sid}")
            sys.exit(f"Only {st['done']}/{target} samples collected. Nothing saved (old data untouched).")
        res = c.post("/api/enrollment/complete", json={"session_id": sid})
        print("\nComplete:", res.json())
        if res.status_code != 200:
            sys.exit(1)


def cmd_recognize(args) -> None:
    last = {"line": None}
    print("Recognizing... press q/Esc in the window or Ctrl+C to stop.\n")

    with client(args) as c:
        def handle(frame):
            r = c.post("/api/face/recognize", files={"file": ("f.jpg", jpeg(frame), "image/jpeg")})
            if r.status_code != 200:
                print("API error:", r.text)
                return [("API error", RED)], False
            d = r.json()
            if d["recognized"]:
                a = d["attendance"] or {}
                text = f"{d['employee']['name']} ({d['employee']['employee_code']})"
                line = (f"RECOGNIZED {text}  score={d['score']} margin={d['margin']}  "
                        f"-> {a.get('action')} {a.get('message', '')}")
                lines = [(text, GREEN), (f"{a.get('action')}  score {d['score']}", GREEN)]
            else:
                line = (f"not recognized: {d['reason']}  score={d.get('score')} margin={d.get('margin')} "
                        f"cand={d.get('candidate')} live={(d.get('liveness') or {}).get('label')}  "
                        f"{HINTS.get(d['reason'], '')}")
                lines = [(HINTS.get(d["reason"], d["reason"] or "unknown"), RED)]
                if d.get("score") is not None:
                    lines.append((f"closest score {d['score']}", YELLOW))
            if line != last["line"]:
                print(time.strftime("%H:%M:%S"), line)
                last["line"] = line
            return lines, False

        try:
            run_loop(args, handle, "Recognition (q = stop)")
        except KeyboardInterrupt:
            pass
    print("\nStopped.")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", default="http://localhost:8000")
    ap.add_argument("--api-key", default="")
    ap.add_argument("--camera", default="0")
    ap.add_argument("--source", default="")
    ap.add_argument("--preview", action="store_true")
    ap.add_argument("--width", type=int, default=1280)
    ap.add_argument("--height", type=int, default=720)
    ap.add_argument("--interval", type=float, default=0.5)
    sub = ap.add_subparsers(dest="cmd", required=True)
    e = sub.add_parser("enroll")
    e.add_argument("--code", required=True)
    e.add_argument("--name", required=True)
    e.add_argument("--office", default="KADAP")
    e.add_argument("--pause", type=float, default=1.2, help="seconds to change pose after each accepted sample")
    e.add_argument("--max-tries", type=int, default=200)
    sub.add_parser("recognize")
    args = ap.parse_args()
    {"enroll": cmd_enroll, "recognize": cmd_recognize}[args.cmd](args)


if __name__ == "__main__":
    main()
