# Testing
`cd backend && python -m pytest -q` runs 26 tests: SCRFD keypoint decoding, NMS, alignment, matcher (threshold/margin), daily classification,
payroll maths (hand-calculated month, determinism, statutory defaults, divisor bases, rounding, caps), and an API flow for
enrollment, recognition, attendance, leave, holidays, payroll workflow + locking + audit, reports, dashboard, errors.
Tests use a FAKE ML pipeline (no ONNX needed) and SQLite by default; set DATABASE_URL=postgresql+psycopg2://... to run them on PostgreSQL.
Real-model checks: run the server (`/api/system/models`) and `scripts/webcam_client.py`.
Frontend: `npm run typecheck` and `npm run build`. There are no automated browser tests.
