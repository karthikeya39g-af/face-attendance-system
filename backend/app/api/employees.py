from datetime import date, timedelta
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.security import require_api_key
from app.db.models import AttendanceEvent, PayrollPeriod, PayrollRecord, SalaryProfile
from app.db.session import get_db
from app.schemas.employee import EmployeeCreate, EmployeeUpdate
from app.repositories.employee_repository import EmployeeRepository
from app.services.attendance_calc import AttendanceCalcService
from app.services.employee_service import EmployeeError, EmployeeService
from app.services.payroll_service import PayrollService
from app.utils.time import today_local

router = APIRouter(prefix="/api/employees", tags=["employees"], dependencies=[Depends(require_api_key)])
svc = EmployeeService()


def _wrap(fn, *a):
    try:
        return fn(*a)
    except EmployeeError as e:
        raise HTTPException(e.status, e.code)


@router.get("")
def list_employees(db: Session = Depends(get_db)):
    return svc.list(db)


@router.get("/{employee_code}")
def get_employee(employee_code: str, db: Session = Depends(get_db)):
    return _wrap(svc.get, db, employee_code)


@router.post("", status_code=201)
def create_employee(body: EmployeeCreate, db: Session = Depends(get_db)):
    return _wrap(svc.create, db, body.employee_code, body.name, body.office_code,
                 body.department, body.designation, body.email, body.phone)


@router.patch("/{employee_code}")
def update_employee(employee_code: str, body: EmployeeUpdate, db: Session = Depends(get_db)):
    return _wrap(svc.update, db, employee_code, body.name, body.office_code,
                 body.department, body.designation, body.email, body.phone)


@router.delete("/{employee_code}")
def delete_employee(employee_code: str, request: Request, db: Session = Depends(get_db)):
    _wrap(svc.deactivate, db, employee_code)
    request.app.state.enrollment.reload_gallery(db)  # remove from live gallery
    return {"deactivated": True}


class SalaryProfileIn(BaseModel):
    basic_salary: Decimal = Field(ge=0, default=0)
    hra: Decimal = Field(ge=0, default=0)
    transport_allowance: Decimal = Field(ge=0, default=0)
    medical_allowance: Decimal = Field(ge=0, default=0)
    special_allowance: Decimal = Field(ge=0, default=0)
    other_allowance: Decimal = Field(ge=0, default=0)
    overtime_rate: Decimal = Field(ge=0, default=0)
    working_hours_per_day: float = Field(8.0, gt=0, le=24)
    working_days_per_month: float = Field(26.0, gt=0, le=31)
    pf_enabled: bool = False
    esi_enabled: bool = False
    professional_tax: Decimal = Field(ge=0, default=0)
    other_fixed_deduction: Decimal = Field(ge=0, default=0)
    effective_from: date | None = None


SAL_FIELDS = ["basic_salary", "hra", "transport_allowance", "medical_allowance", "special_allowance", "other_allowance",
              "overtime_rate", "working_hours_per_day", "working_days_per_month", "pf_enabled", "esi_enabled",
              "professional_tax", "other_fixed_deduction"]


def salary_dict(sp: SalaryProfile | None) -> dict | None:
    if sp is None:
        return None
    d = {k: (float(getattr(sp, k)) if isinstance(getattr(sp, k), Decimal) else getattr(sp, k)) for k in SAL_FIELDS}
    d["effective_from"] = sp.effective_from.isoformat()
    return d


def _emp(db: Session, code: str):
    e = EmployeeRepository(db).by_code(code)
    if not e:
        raise HTTPException(404, "employee_not_found")
    return e


def _latest_salary(db: Session, emp_id: int, on: date | None = None):
    q = select(SalaryProfile).where(SalaryProfile.employee_id == emp_id)
    if on:
        q = q.where(SalaryProfile.effective_from <= on)
    return db.scalars(q.order_by(SalaryProfile.effective_from.desc())).first()


@router.get("/{employee_code}/salary-profile")
def get_salary_profile(employee_code: str, db: Session = Depends(get_db)):
    return salary_dict(_latest_salary(db, _emp(db, employee_code).id))


@router.put("/{employee_code}/salary-profile")
def put_salary_profile(employee_code: str, body: SalaryProfileIn, db: Session = Depends(get_db),
                       s: Settings = Depends(get_settings)):
    """New effective_from creates a new row (history kept); same date updates that row."""
    emp = _emp(db, employee_code)
    eff = body.effective_from or today_local(s.TIMEZONE)
    sp = db.scalar(select(SalaryProfile).where(SalaryProfile.employee_id == emp.id, SalaryProfile.effective_from == eff))
    if sp is None:
        sp = SalaryProfile(employee_id=emp.id, effective_from=eff)
        db.add(sp)
    for k in SAL_FIELDS:
        setattr(sp, k, getattr(body, k))
    db.commit()
    return salary_dict(sp)


@router.get("/{employee_code}/profile")
def profile(employee_code: str, db: Session = Depends(get_db), s: Settings = Depends(get_settings)):
    emp = _emp(db, employee_code)
    today = today_local(s.TIMEZONE)
    calc = AttendanceCalcService(db, s)
    rng = calc.compute_range([emp.id], today.replace(day=1), today)[emp.id]
    days = list(rng.values())
    counted = [d for d in days if d.status not in ("FUTURE", "NOT_ARRIVED")]
    t = rng[today]
    month = {
        "present": sum(1 for d in counted if d.status in ("PRESENT", "LATE")),
        "half_day": sum(1 for d in counted if d.status == "HALF_DAY"),
        "absent": sum(1 for d in counted if d.status == "ABSENT"),
        "on_leave": sum(1 for d in counted if d.status == "ON_LEAVE"),
        "late": sum(1 for d in counted if d.late_minutes > 0),
        "early_checkout": sum(1 for d in counted if d.early_minutes > 0),
        "total_hours": round(sum(d.worked_minutes for d in days) / 60, 2),
        "overtime_hours": round(sum(d.overtime_minutes for d in days) / 60, 2),
        "days": [{"date": d.date.isoformat(), "status": d.status, "worked_minutes": d.worked_minutes,
                  "late_minutes": d.late_minutes, "overtime_minutes": d.overtime_minutes} for d in days],
    }
    latest = db.scalars(select(PayrollRecord).join(PayrollPeriod, PayrollPeriod.id == PayrollRecord.payroll_period_id)
                        .where(PayrollRecord.employee_id == emp.id)
                        .order_by(PayrollPeriod.period_year.desc(), PayrollPeriod.period_month.desc())).first()
    events = db.scalars(select(AttendanceEvent).where(AttendanceEvent.employee_id == emp.id)
                        .order_by(AttendanceEvent.id.desc()).limit(15))
    n_emb = EmployeeRepository(db).embedding_counts().get(emp.id, 0)
    return {
        "employee": {"employee_code": emp.employee_code, "name": emp.name, "office": emp.office.code,
                     "department": emp.department, "designation": emp.designation,
                     "email": emp.email, "phone": emp.phone,
                     "is_active": emp.is_active, "created_at": emp.created_at.isoformat() if emp.created_at else None},
        "face": {"enrolled": n_emb > 0, "embedding_count": n_emb},
        "today": {"status": t.status, "worked_minutes": t.worked_minutes, "late_minutes": t.late_minutes,
                  "currently_working": t.currently_working},
        "month": month,
        "salary_profile": salary_dict(_latest_salary(db, emp.id)),
        "latest_payroll": PayrollService.record_dict(latest) if latest else None,
        "recent_events": [{"type": e.event_type, "similarity": e.similarity,
                           "at": e.created_at.isoformat() if e.created_at else None} for e in events],
    }
