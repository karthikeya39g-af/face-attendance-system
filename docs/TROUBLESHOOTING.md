# Troubleshooting
- Backend won't start: read the first error. Missing model -> `python -m scripts.download_models`. DB refused -> check the PORT in DATABASE_URL (`pg_lsclusters`).
- "Backend offline" in the UI: backend not running on :8000 (or set VITE_BACKEND_URL).
- Camera black / denied: allow it in the browser address bar; close other apps using the webcam; use localhost or HTTPS.
- Many `image_too_blurry`: more light, hold still, check `quality.blur_score`; tune MIN_BLUR_SCORE carefully.
- Real face flagged `spoof_detected`: step closer / better light; see liveness values in Recognition -> Developer mode.
- Payroll "skipped_no_salary_profile": add a salary profile to those employees, then Recalculate.
- Everyone ABSENT: shifts, week-off and policy are applied; check Shifts and Settings.
