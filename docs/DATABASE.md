# Database (PostgreSQL, SQLAlchemy 2)
Original: offices, employees, face_embeddings (512 float32 bytes), attendance (unique employee+date), attendance_events.
Added in 3.1: app_settings (policy JSON), work_shifts, employee_shifts, holidays, leave_types, leave_requests,
salary_profiles (unique employee+effective_from, history kept), payroll_periods (unique year+month), payroll_records
(unique period+employee, `breakdown` JSON), payroll_adjustments, payroll_audit_log.
Tables are created additively by `init_db()` on startup (`create_all`): existing tables/rows are never dropped or altered.
There are NO Alembic migrations yet: a future column change on an existing table must be applied by hand.
Embeddings are not logged. Employee delete = deactivate (history kept).
