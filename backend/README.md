# Face Attendance V3 — Backend

FastAPI + ONNX Runtime + PostgreSQL.
Pipeline: SCRFD (detect) -> quality -> MiniFASNetV2 (liveness) -> ArcFace align -> w600k_mbf (512-D) -> gallery matcher -> attendance.

## 1. Prerequisites
- Python 3.10+ (3.11/3.12 fine)
- PostgreSQL 14+ (or Docker)
- Your three model files

## 2. Install the models (automatic)
After step 4 (virtual env + `pip install`), run from `backend/`:
```
python -m scripts.download_models
```
This downloads about 120 MB once (the InsightFace `buffalo_s` pack, from which only two files are used) plus the 1.7 MB liveness model, and places:
```
models/detection/scrfd_500m_kps.onnx     (= det_500m.onnx, SCRFD 500M with keypoints)
models/recognition/w600k_mbf.onnx
models/liveness/MiniFASNetV2.onnx        (from yakhyo/face-anti-spoofing releases)
```
If you already have these files from V1/V2, just copy them to those paths instead.

Licence note: InsightFace's pretrained models are for non-commercial research. Check their terms before using this in a commercial product.

## 3. Start PostgreSQL
Docker:
```
docker compose up -d
```
Or local Postgres:
```
createdb attendance_v3
```
Then edit `DATABASE_URL` in `.env` if your user/password differ.

## 4. Create the environment and install
Windows (PowerShell):
```
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```
Linux/macOS:
```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## 5. Run the tests (no models needed, uses a fake ML pipeline + SQLite)
```
python -m pytest -q
```

## 6. Start the server
```
uvicorn app.main:app --reload --port 8000
```
On startup it creates tables, seeds offices (KADAP, TIRUPATI), loads and smoke-tests all 3 models, and loads the gallery.
If a model is missing or has the wrong shape, the app refuses to start and tells you which one.

Open http://localhost:8000/docs

## 7. Verify step by step
1. `GET /health`
2. `GET /api/system/models` -> check detector has 9 outputs, liveness input `[1,3,80,80]`, recognizer embedding_dim 512
3. `GET /api/system/database`
4. Enroll via Swagger or curl:
```
curl -X POST localhost:8000/api/enrollment/start -H "Content-Type: application/json" \
  -d '{"employee_code":"126","name":"Test Employee","office_code":"KADAP"}'
curl -X POST localhost:8000/api/enrollment/sample -F session_id=<ID> -F file=@face.jpg
curl -X POST localhost:8000/api/enrollment/complete -H "Content-Type: application/json" -d '{"session_id":"<ID>"}'
```
Send frames until `captured == target` (default 15). Only `accepted: true` frames count.
5. Recognize: `curl -X POST localhost:8000/api/face/recognize -F file=@face.jpg`
6. `GET /api/attendance/today`

## 7b. Enroll and recognize with your webcam (no frontend needed)
```
ls /dev/video*                       # confirm a camera exists
python -m scripts.webcam_client --preview enroll --code 123 --name "Karthikeya" --office KADAP
python -m scripts.webcam_client --preview recognize
```
Enroll prints a pose prompt after every accepted sample and a hint for every rejected frame. Use `--camera 1` for a different webcam, or `--source folder_or_video` to use files.

## 8. Calibrate (important)
After enrolling several people:
```
python -m scripts.diagnose_gallery
```
Choose `RECOGNITION_THRESHOLD` between the inter-person p99 and intra-person p5, then set it in `.env`. Do not just lower it to hide bad enrollments.

## Things to check against YOUR model files
- Liveness class order: `LIVENESS_REAL_INDEX=1` is the Silent-Face default. Send a real face and a phone photo to `/api/face/recognize` and check `liveness.probs`; if the values are swapped, change the index.
- Blur scores are computed on the face crop normalised to 160x160. Look at `quality.blur_score` for good frames and set `MIN_BLUR_SCORE` below them.
- If detection fails on real images, check `/api/system/models` output shapes first.

## Layout
```
app/
  main.py            startup (models + gallery loaded once)
  core/              config, logging, optional API-key auth
  db/                SQLAlchemy models, session, init
  repositories/      all SQL lives here
  services/          business logic (recognition, enrollment, attendance, employees)
  ml/                detector, liveness, alignment, recognizer, matcher, pipeline, model_manager
  api/               thin routers
  utils/             image, quality, similarity, time
scripts/diagnose_gallery.py
tests/
```

## Design rules implemented
- Models loaded once (ModelManager); startup fails if invalid.
- Enrollment is an in-memory session; old embeddings are replaced only inside the final DB transaction.
- Rejected frames never advance the counter.
- Duplicate-frame, centroid-consistency and cross-employee similarity guards at enrollment.
- Matching uses threshold + margin; reasons returned (`below_threshold`, `insufficient_margin`).
- One attendance row per employee per day (unique constraint); events table is the audit log.
- Delete = soft-deactivate (history kept, removed from live gallery).

## Production notes
Set `API_KEY` (clients send `X-API-Key`), restrict `CORS_ORIGINS`, run behind HTTPS (browsers require it for the camera off localhost), and run one uvicorn worker unless you move enrollment sessions to Redis.

## Live preview for the webcam client
`--preview` needs the GUI build of OpenCV (the default in requirements.txt is the headless one):
```
pip uninstall -y opencv-python-headless
pip install opencv-python
```
Global flags such as `--preview` and `--camera` go BEFORE `enroll`/`recognize`.
