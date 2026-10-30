from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.security import require_api_key
from app.db.session import get_db
from sqlalchemy import select
from sqlalchemy.orm import joinedload

from app.db.models import Employee
from app.repositories.attendance_repository import AttendanceRepository
from app.services.attendance_calc import AttendanceCalcService
from app.utils.time import to_local
from app.repositories.employee_repository import EmployeeRepository
from app.schemas.attendance import ManualAttendance
from app.services.attendance_service import AttendanceService
from app.utils.time import today_local

router = APIRouter(prefix="/api/attendance", tags=["attendance"], dependencies=[Depends(require_api_key)])


def _row(a) -> dict:
    return {
        "employee_code": a.employee.employee_code, "name": a.employee.name,
        "date": a.attendance_date.isoformat(),
        "check_in": a.check_in_time.isoformat() if a.check_in_time else None,
        "check_out": a.check_out_time.isoformat() if a.check_out_time else None,
        "check_in_similarity": a.check_in_similarity, "check_out_similarity": a.check_out_similarity,
        "status": a.status,
    }


@router.get("/today")
def today(db: Session = Depends(get_db), s: Settings = Depends(get_settings)):
    return [_row(a) for a in AttendanceRepository(db).list_day(today_local(s.TIMEZONE))]


@router.get("/daily")
def daily(day: date | None = None, office: str | None = None, status: str | None = None, q: str | None = None,
          limit: int = 200, offset: int = 0, db: Session = Depends(get_db), s: Settings = Depends(get_settings)):
    """Every active employee for the day with computed status/hours/late/overtime (absent ones included)."""
    day = day or today_local(s.TIMEZONE)
    emps = [e for e in db.scalars(select(Employee).options(joinedload(Employee.office))
                                  .where(Employee.is_active.is_(True)).order_by(Employee.employee_code))
            if (not office or e.office.code == office)
            and (not q or q.lower() in e.name.lower() or q in e.employee_code)]
    rng = AttendanceCalcService(db, s).compute_range([e.id for e in emps], day, day)
    att = {a.employee_id: a for a in AttendanceRepository(db).list_day(day)}
    rows = []
    for e in emps:
        r, a = rng[e.id][day], att.get(e.id)
        rows.append({
            "employee_code": e.employee_code, "name": e.name, "office": e.office.code, "status": r.status,
            "check_in": a.check_in_time.isoformat() if a and a.check_in_time else None,
            "check_out": a.check_out_time.isoformat() if a and a.check_out_time else None,
            "worked_minutes": r.worked_minutes, "late_minutes": r.late_minutes, "early_minutes": r.early_minutes,
            "overtime_minutes": r.overtime_minutes, "currently_working": r.currently_working, "incomplete": r.incomplete,
            "shift": r.shift_name, "score": a.check_in_similarity if a else None})
    if status:
        want = status.upper()
        rows = [x for x in rows if x["status"] == want or (want == "LATE" and x["late_minutes"] > 0)
                or (want == "OVERTIME" and x["overtime_minutes"] > 0) or (want == "WORKING" and x["currently_working"])]
    return {"date": day.isoformat(), "total": len(rows), "rows": rows[offset: offset + min(limit, 1000)]}


@router.get("/history")
def history(start: date | None = None, end: date | None = None, limit: int = 500,
            db: Session = Depends(get_db)):
    return [_row(a) for a in AttendanceRepository(db).history(start, end, None, min(limit, 2000))]


@router.get("/employee/{employee_code}")
def employee_history(employee_code: str, db: Session = Depends(get_db)):
    emp = EmployeeRepository(db).by_code(employee_code)
    if not emp:
        raise HTTPException(404, "employee_not_found")
    return [_row(a) for a in AttendanceRepository(db).history(None, None, emp.id)]


def _manual(kind: str, body: ManualAttendance, db: Session, s: Settings):
    emp = EmployeeRepository(db).by_code(body.employee_code)
    if not emp or not emp.is_active:
        raise HTTPException(404, "employee_not_found")
    result = AttendanceService(s).mark(db, emp, None, force=kind)
    db.commit()
    return result


@router.post("/check-in")
def check_in(body: ManualAttendance, db: Session = Depends(get_db), s: Settings = Depends(get_settings)):
    return _manual("CHECK_IN", body, db, s)


@router.post("/check-out")
def check_out(body: ManualAttendance, db: Session = Depends(get_db), s: Settings = Depends(get_settings)):
    return _manual("CHECK_OUT", body, db, s)
