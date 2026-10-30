from datetime import date, timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.core.config import Settings
from app.db.models import Employee, Holiday, LeaveRequest, LeaveType
from app.services.policy import get_policy
from app.utils.time import now_local


class LeaveError(Exception):
    def __init__(self, code: str, status: int = 400, message: str | None = None):
        self.code, self.status, self.message = code, status, message or code


class LeaveService:
    def __init__(self, settings: Settings):
        self.s = settings

    def create(self, db: Session, employee_code: str, leave_type: str, start: date, end: date, reason: str | None):
        emp = db.scalar(select(Employee).where(Employee.employee_code == employee_code))
        if not emp or not emp.is_active:
            raise LeaveError("employee_not_found", 404)
        lt = db.scalar(select(LeaveType).where(LeaveType.code == leave_type))
        if not lt:
            raise LeaveError("unknown_leave_type", 422)
        if end < start:
            raise LeaveError("end_before_start", 422)
        clash = db.scalar(select(LeaveRequest).where(
            LeaveRequest.employee_id == emp.id, LeaveRequest.status.in_(["PENDING", "APPROVED"]),
            LeaveRequest.start_date <= end, LeaveRequest.end_date >= start))
        if clash:
            raise LeaveError("leave_overlaps_existing", 409, "Overlaps an existing pending/approved leave.")
        policy = get_policy(db)
        holidays = set(db.scalars(select(Holiday.holiday_date).where(
            Holiday.holiday_date >= start, Holiday.holiday_date <= end)))
        days, d = 0.0, start
        while d <= end:
            if d.weekday() not in policy.week_off_days and d not in holidays:
                days += 1
            d += timedelta(days=1)
        if days == 0:
            raise LeaveError("no_working_days_in_range", 422, "The range contains only week-offs/holidays.")
        lr = LeaveRequest(employee_id=emp.id, leave_type_id=lt.id, start_date=start, end_date=end,
                          days=days, reason=reason, status="PENDING")
        db.add(lr)
        db.commit()
        return lr

    def decide(self, db: Session, request_id: int, action: str, actor: str):
        lr = db.get(LeaveRequest, request_id)
        if not lr:
            raise LeaveError("leave_not_found", 404)
        allowed = {"approve": ({"PENDING"}, "APPROVED"), "reject": ({"PENDING"}, "REJECTED"),
                   "cancel": ({"PENDING", "APPROVED"}, "CANCELLED")}
        frm, to = allowed[action]
        if lr.status not in frm:
            raise LeaveError("invalid_transition", 409, f"Cannot {action} a {lr.status} request.")
        lr.status, lr.approved_by, lr.decided_at = to, actor, now_local(self.s.TIMEZONE)
        db.commit()
        return lr

    @staticmethod
    def to_dict(lr: LeaveRequest) -> dict:
        return {"id": lr.id, "employee_code": lr.employee.employee_code, "name": lr.employee.name,
                "leave_type": lr.leave_type.code, "leave_type_name": lr.leave_type.name, "paid": lr.leave_type.is_paid,
                "start_date": lr.start_date.isoformat(), "end_date": lr.end_date.isoformat(), "days": lr.days,
                "reason": lr.reason, "status": lr.status, "approved_by": lr.approved_by}

    def list(self, db: Session, status: str | None = None, employee_code: str | None = None):
        q = select(LeaveRequest).options(joinedload(LeaveRequest.employee), joinedload(LeaveRequest.leave_type)) \
            .order_by(LeaveRequest.id.desc()).limit(500)
        if status:
            q = q.where(LeaveRequest.status == status)
        if employee_code:
            q = q.join(Employee, Employee.id == LeaveRequest.employee_id).where(Employee.employee_code == employee_code)
        return [self.to_dict(x) for x in db.scalars(q).unique()]
