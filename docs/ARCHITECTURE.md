# Architecture
```
React (Vite) --REST--> FastAPI --> services --> ML (ONNX) / repositories --> PostgreSQL
```
- `api/` thin routers; `services/` business logic; `ml/` models + pipeline; `repositories/` SQL; `db/` models.
- One `ModelManager` loads the 3 ONNX models at startup (the app refuses to start if one is missing/invalid).
- One gallery matcher keeps employee embeddings in memory; reloaded after enrollment/deactivation.
- Attendance classification lives ONLY in `services/attendance_calc.py`; payroll maths ONLY in `services/payroll_service.py`.
- Frontend: one `CameraProvider` owns the single MediaStream (ref-counted). Each page's `CameraView` attaches the existing
  stream to its own video element; tracks stop 2 s after the last user leaves, so page changes reuse the live stream.
- Errors: `{"success": false, "error": {"code","message","details"}}` (legacy `detail` kept).
