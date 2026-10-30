# Face Attendance & Payroll (V3.1)

FastAPI + ONNX Runtime + PostgreSQL backend, React + Vite + TypeScript + Tailwind frontend.

```
camera -> SCRFD -> quality -> MiniFASNetV2 liveness -> ArcFace align -> w600k_mbf -> matcher -> attendance -> hours/OT/late -> payroll
```
Face recognition only establishes identity + attendance. Payroll consumes verified attendance and applies configurable rules.

## Run (Debian)
```bash
# 1) backend (from backend/)
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env        # set DATABASE_URL (your PostgreSQL port!)
python -m scripts.download_models
python -m pytest -q
uvicorn app.main:app --port 8000

# 2) frontend (from frontend/, second terminal)
npm install
npm run dev                 # http://localhost:5173
```
Open http://localhost:5173. API docs: http://localhost:8000/docs

## Upgrading an existing V3 install (keeps your data)
Copy the new `backend/app`, `backend/scripts`, `backend/tests` over the old ones. Keep your `.env`, `.venv` and `models/`.
No new Python packages. On startup the backend ADDS the new tables (payroll, leave, shifts, holidays, settings) and leaves
existing tables/rows untouched. Replace the whole `frontend/` folder and run `npm install` again.

See `docs/` for architecture, ML pipeline, database, attendance rules, payroll, API, deployment, troubleshooting and testing.
