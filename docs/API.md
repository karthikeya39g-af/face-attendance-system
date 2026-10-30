# API (interactive docs: /docs and /redoc)
System: GET /health, /api/system/models, /api/system/database, /api/system/config
Employees: GET/POST /api/employees, GET/PATCH/DELETE /api/employees/{code}, GET /{code}/profile, GET/PUT /{code}/salary-profile
Enrollment: POST /api/enrollment/start | /sample | /complete | /cancel/{id} (DELETE also works)
Recognition: POST /api/face/recognize (multipart `file`; returns bbox, score, second_score, margin, liveness, quality, reason, attendance)
Attendance: GET /api/attendance/today | /daily | /history | /employee/{code}; POST /check-in | /check-out (manual)
Payroll: GET /api/payroll/dashboard | /periods | /periods/{id} | /records | /records/{id} | /employee/{code}[/history];
  POST /periods, /periods/{id}/calculate|approve|process|pay, /adjustments
Leave: GET /api/leave/types | /requests; POST /requests, /requests/{id}/approve|reject|cancel
Shifts: GET/POST /api/shifts, PUT /shifts/{id}, GET /shifts/assignments, POST /shifts/assign; GET/POST/DELETE /api/holidays
Offices: GET/POST /api/offices, PATCH /api/offices/{code}
Settings: GET/PUT /api/settings/policy
Reports: GET /api/reports/{attendance|late|overtime|leave|payroll|events}?start&end&office&employee&period_id&format=csv
Dashboard: GET /api/dashboard/summary?office&days
Optional shared secret: set API_KEY in backend .env and VITE_API_KEY in frontend .env (header X-API-Key).
