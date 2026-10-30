import csv
import io
from datetime import date, timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.core.config import Settings
from app.db.models import AttendanceEvent, Employee, PayrollRecord
from app.services.attendance_calc import AttendanceCalcService
from app.services.leave_service import LeaveService
from app.services.payroll_service import PayrollService

hm = lambda m: f"{m // 60}h {m % 60:02d}m"  # noqa: E731


class ReportService:
    NAMES = ["attendance", "late", "overtime", "leave", "payroll", "events"]

    def __init__(self, settings: Settings):
        self.s = settings

    def build(self, db: Session, name: str, start: date | None, end: date | None, office: str | None,
              employee: str | None, period_id: int | None) -> tuple[list[str], list[list]]:
        end = end or date.today()
        start = start or (end - timedelta(days=29))
        if name in ("attendance", "late", "overtime"):
            return self._attendance(db, name, start, end, office, employee)
        if name == "leave":
            rows = LeaveService(self.s).list(db, None, employee)
            rows = [r for r in rows if r["end_date"] >= start.isoformat() and r["start_date"] <= end.isoformat()]
            cols = ["employee_code", "name", "leave_type", "paid", "start_date", "end_date", "days", "status", "approved_by", "reason"]
            return cols, [[r[c] for c in cols] for r in rows]
        if name == "payroll":
            q = select(PayrollRecord).options(joinedload(PayrollRecord.employee).joinedload(Employee.office)) \
                .order_by(PayrollRecord.employee_id)
            if period_id:
                q = q.where(PayrollRecord.payroll_period_id == period_id)
            recs = list(db.scalars(q).unique())
            cols = ["period_id", "employee_code", "name", "present_days", "absent_days", "half_days", "leave_days",
                    "overtime_hours", "basic_salary", "hra", "allowances", "bonus", "overtime_pay", "gross_salary",
                    "pf_deduction", "esi_deduction", "professional_tax", "other_deductions", "unpaid_leave_deduction",
                    "total_deductions", "net_salary", "status"]
            return cols, [[PayrollService.record_dict(r)[c] for c in cols] for r in recs]
        if name == "events":
            evs = list(db.scalars(select(AttendanceEvent).order_by(AttendanceEvent.id.desc()).limit(2000)))
            cols = ["time", "type", "employee_id", "similarity", "details"]
            return cols, [[e.created_at.isoformat() if e.created_at else "", e.event_type, e.employee_id,
                           e.similarity, e.details] for e in evs]
        raise ValueError("unknown_report")

    def _attendance(self, db, name, start, end, office, employee):
        q = select(Employee).options(joinedload(Employee.office)).where(Employee.is_active.is_(True))
        emps = [e for e in db.scalars(q) if (not office or e.office.code == office)
                and (not employee or e.employee_code == employee)]
        rng = AttendanceCalcService(db, self.s).compute_range([e.id for e in emps], start, end)
        cols = ["date", "employee_code", "name", "office", "status", "worked", "late_minutes", "early_minutes", "overtime_minutes"]
        rows = []
        for e in emps:
            for d, r in rng[e.id].items():
                if r.status in ("FUTURE", "NOT_ARRIVED"):
                    continue
                if name == "late" and r.late_minutes == 0:
                    continue
                if name == "overtime" and r.overtime_minutes == 0:
                    continue
                rows.append([d.isoformat(), e.employee_code, e.name, e.office.code, r.status, hm(r.worked_minutes),
                             r.late_minutes, r.early_minutes, r.overtime_minutes])
        rows.sort(key=lambda x: (x[0], x[1]), reverse=True)
        return cols, rows

    @staticmethod
    def to_csv(cols, rows) -> str:
        buf = io.StringIO()
        w = csv.writer(buf)
        w.writerow(cols)
        for r in rows:
            w.writerow(["" if v is None else v for v in r])
        return buf.getvalue()
