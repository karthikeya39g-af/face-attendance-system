from sqlalchemy.orm import Session

from app.db.base import Base
from datetime import time

from app.db.models import LeaveType, Office, WorkShift

DEFAULT_LEAVE_TYPES = [("CASUAL", "Casual Leave", True), ("SICK", "Sick Leave", True),
                       ("EARNED", "Earned Leave", True), ("UNPAID", "Unpaid Leave", False), ("OTHER", "Other", True)]
DEFAULT_OFFICES = [("KADAP", "Kadap Office"), ("TIRUPATI", "Tirupati Office")]


from sqlalchemy import text

def init_db(engine) -> None:
    Base.metadata.create_all(bind=engine)
    with engine.connect() as conn:
        for col, typ in [("department", "VARCHAR(64)"), ("designation", "VARCHAR(64)"),
                         ("email", "VARCHAR(128)"), ("phone", "VARCHAR(32)")]:
            try:
                conn.execute(text(f"ALTER TABLE employees ADD COLUMN IF NOT EXISTS {col} {typ}"))
                conn.commit()
            except Exception:
                pass
    with Session(engine) as db:
        for code, name in DEFAULT_OFFICES:
            if not db.query(Office).filter_by(code=code).first():
                db.add(Office(code=code, name=name))
        if not db.query(WorkShift).first():
            db.add(WorkShift(name="General Shift", start_time=time(9, 0), end_time=time(18, 0),
                             break_minutes=60, grace_minutes=15, required_hours=8.0, is_default=True))
        for code, name, paid in DEFAULT_LEAVE_TYPES:
            if not db.query(LeaveType).filter_by(code=code).first():
                db.add(LeaveType(code=code, name=name, is_paid=paid))
        db.commit()
