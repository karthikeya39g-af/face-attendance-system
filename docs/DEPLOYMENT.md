# Deployment notes
- Set a strong PostgreSQL password and API_KEY; restrict CORS_ORIGINS.
- Browsers allow the camera only on http://localhost or HTTPS: serve the built frontend (`npm run build` -> dist/) behind HTTPS and proxy /api and /health to the backend.
- Run ONE backend worker (enrollment sessions are in memory).
- Back up PostgreSQL (pg_dump), especially the payroll tables.
- There is no user login yet. Do not expose this to the internet before adding authentication.
- InsightFace pretrained models are non-commercial: check licensing for company use.
