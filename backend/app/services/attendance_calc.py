"""Single source of truth for daily attendance classification, hours, late, early, overtime."""
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import date, datetime, time, timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.db.models import Attendance, EmployeeShift, Holiday, LeaveRequest, LeaveType, WorkShift
from app.services.policy import Policy, get_policy
from app.utils.time import now_local, to_local


@dataclass
class ShiftInfo:
    name: str
    start: time
    end: time
    break_minutes: int
    grace_minutes: int
    required_minutes: int


BUILTIN_SHIFT = ShiftInfo("General Shift", time(9, 0), time(18, 0), 60, 15, 480)


@dataclass
class LeaveInfo:
    code: str
    is_paid: bool


@dataclass
class DayResult:
    date: date
    status: str = ""             # PRESENT LATE HALF_DAY ABSENT ON_LEAVE HOLIDAY WEEK_OFF NOT_ARRIVED FUTURE
    checked_in: bool = False
    currently_working: bool = False
    incomplete: bool = False     # checked in, never checked out (past day)
    short_hours: bool = False
    worked_minutes: int = 0
    required_minutes: int = 0
    overtime_minutes: int = 0
    late_minutes: int = 0
    early_minutes: int = 0
    leave_paid: bool | None = None
    leave_code: str | None = None
    shift_name: str = ""


def _net(a: datetime, b: datetime, brk: int) -> int:
    span = max(0, int((b - a).total_seconds() // 60))
    return span - brk if span > brk else span


def compute_day(day: date, rec, shift: ShiftInfo, leave: LeaveInfo | None, is_holiday: bool,
                is_weekoff: bool, policy: Policy, now: datetime) -> DayResult:
    tz = now.tzinfo
    today = now.date()
    r = DayResult(date=day, required_minutes=shift.required_minutes, shift_name=shift.name)
    ci = to_local(rec.check_in_time, str(tz)) if rec is not None and rec.check_in_time else None

    if ci is None:
        if is_holiday:
            r.status = "HOLIDAY"
        elif is_weekoff:
            r.status = "WEEK_OFF"
        elif leave:
            r.status, r.leave_paid, r.leave_code = "ON_LEAVE", leave.is_paid, leave.code
        elif day > today:
            r.status = "FUTURE"
        elif day == today and now < datetime.combine(day, shift.start, tzinfo=tz) + timedelta(minutes=shift.grace_minutes):
            r.status = "NOT_ARRIVED"
        else:
            r.status = "ABSENT"
        return r

    r.checked_in = True
    s_start = datetime.combine(day, shift.start, tzinfo=tz)
    s_end = datetime.combine(day, shift.end, tzinfo=tz)
    if ci > s_start + timedelta(minutes=shift.grace_minutes):
        r.late_minutes = int((ci - s_start).total_seconds() // 60)
    present_status = "LATE" if r.late_minutes else "PRESENT"

    co = to_local(rec.check_out_time, str(tz)) if rec.check_out_time else None
    if co is None:
        if day == today:
            r.currently_working = True
            r.worked_minutes = _net(ci, now, shift.break_minutes)
            r.status = present_status
            return r
        r.incomplete = True
        if policy.missing_checkout_policy == "assume_required":
            r.worked_minutes, r.status = shift.required_minutes, present_status
        elif policy.missing_checkout_policy == "half_day":
            r.status = "HALF_DAY"
        else:
            r.status = "ABSENT"
        return r

    r.worked_minutes = _net(ci, co, shift.break_minutes)
    if co < s_end - timedelta(minutes=policy.early_checkout_threshold_minutes):
        r.early_minutes = int((s_end - co).total_seconds() // 60)
    excess = r.worked_minutes - shift.required_minutes
    if excess > 0 and excess >= policy.overtime_threshold_minutes:
        r.overtime_minutes = excess

    full_min = min(policy.full_day_min_hours * 60, shift.required_minutes)
    if r.worked_minutes >= full_min:
        r.status = present_status
    elif r.worked_minutes >= policy.half_day_min_hours * 60:
        r.status = "HALF_DAY"
    else:
        r.status, r.short_hours = "ABSENT", True
    return r


class AttendanceCalcService:
    def __init__(self, db: Session, settings: Settings):
        self.db, self.s = db, settings
        self.policy = get_policy(db)

    def _default_shift(self, shifts: dict[int, WorkShift]) -> ShiftInfo:
        for sh in shifts.values():
            if sh.is_default:
                return self._info(sh)
        return next((self._info(sh) for sh in shifts.values()), BUILTIN_SHIFT)

    @staticmethod
    def _info(sh: WorkShift) -> ShiftInfo:
        return ShiftInfo(sh.name, sh.start_time, sh.end_time, sh.break_minutes, sh.grace_minutes,
                         int(round(sh.required_hours * 60)))

    def compute_range(self, employee_ids: list[int], start: date, end: date,
                      now: datetime | None = None) -> dict[int, dict[date, DayResult]]:
        now = now or now_local(self.s.TIMEZONE)
        db = self.db
        att = {(a.employee_id, a.attendance_date): a for a in db.scalars(select(Attendance).where(
            Attendance.employee_id.in_(employee_ids), Attendance.attendance_date >= start,
            Attendance.attendance_date <= end))} if employee_ids else {}
        leaves: dict[tuple[int, date], LeaveInfo] = {}
        if employee_ids:
            q = (select(LeaveRequest, LeaveType).join(LeaveType, LeaveType.id == LeaveRequest.leave_type_id)
                 .where(LeaveRequest.employee_id.in_(employee_ids), LeaveRequest.status == "APPROVED",
                        LeaveRequest.start_date <= end, LeaveRequest.end_date >= start))
            for lr, lt in db.execute(q):
                d = max(lr.start_date, start)
                while d <= min(lr.end_date, end):
                    leaves[(lr.employee_id, d)] = LeaveInfo(lt.code, lt.is_paid)
                    d += timedelta(days=1)
        holidays = set(db.scalars(select(Holiday.holiday_date).where(
            Holiday.holiday_date >= start, Holiday.holiday_date <= end)))
        shifts = {s.id: s for s in db.scalars(select(WorkShift).where(WorkShift.is_active.is_(True)))}
        default = self._default_shift(shifts)
        assignments: dict[int, list[EmployeeShift]] = defaultdict(list)
        if employee_ids:
            for es in db.scalars(select(EmployeeShift).where(
                    EmployeeShift.employee_id.in_(employee_ids), EmployeeShift.effective_from <= end)
                    .order_by(EmployeeShift.effective_from)):
                assignments[es.employee_id].append(es)

        def shift_for(emp: int, d: date) -> ShiftInfo:
            chosen = None
            for es in assignments.get(emp, []):
                if es.effective_from <= d and (es.effective_to is None or es.effective_to >= d) and es.shift_id in shifts:
                    chosen = es
            return self._info(shifts[chosen.shift_id]) if chosen else default

        out: dict[int, dict[date, DayResult]] = {}
        for emp in employee_ids:
            days: dict[date, DayResult] = {}
            d = start
            while d <= end:
                days[d] = compute_day(d, att.get((emp, d)), shift_for(emp, d), leaves.get((emp, d)),
                                      d in holidays, d.weekday() in self.policy.week_off_days, self.policy, now)
                d += timedelta(days=1)
            out[emp] = days
        return out
