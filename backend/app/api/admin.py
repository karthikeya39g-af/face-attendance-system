from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.security import require_api_key
from app.db.session import get_db
from app.repositories.attendance_repository import AttendanceRepository, EventRepository
from app.repositories.employee_repository import EmployeeRepository, OfficeRepository
from app.services.employee_service import EmployeeService
from app.utils.time import today_local

router = APIRouter(prefix="/api/admin", tags=["admin"], dependencies=[Depends(require_api_key)])


@router.get("/dashboard")
def dashboard(db: Session = Depends(get_db), s: Settings = Depends(get_settings)):
    repo = EmployeeRepository(db)
    emps = repo.list()
    counts = repo.embedding_counts()
    day = today_local(s.TIMEZONE)
    att = AttendanceRepository(db)
    return {
        "total_employees": len(emps),
        "enrolled_employees": sum(1 for e in emps if counts.get(e.id, 0) > 0),
        "present_today": att.count_day(day),
        "checked_out_today": att.count_day(day, checked_out=True),
    }


@router.get("/employees")
def employees(db: Session = Depends(get_db)):
    return EmployeeService().list(db)


@router.get("/events")
def events(limit: int = 200, event_type: str | None = None, db: Session = Depends(get_db)):
    return [{"id": e.id, "type": e.event_type, "employee_id": e.employee_id, "similarity": e.similarity,
             "details": e.details, "created_at": e.created_at.isoformat() if e.created_at else None}
            for e in EventRepository(db).recent(min(limit, 1000), event_type)]


@router.get("/offices")
def offices(db: Session = Depends(get_db)):
    return [{"code": o.code, "name": o.name} for o in OfficeRepository(db).list()]
