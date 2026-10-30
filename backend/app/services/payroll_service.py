"""Payroll engine. Consumes verified attendance (via AttendanceCalcService); never touches faces.
compute_payroll() is a pure function: same inputs -> same outputs."""
import calendar
from datetime import date, datetime
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.db.models import (Employee, PayrollAdjustment, PayrollAudit, PayrollPeriod, PayrollRecord, SalaryProfile)
from app.services.attendance_calc import AttendanceCalcService, DayResult
from app.services.policy import Policy
from app.utils.time import now_local

D = Decimal
TRANSITIONS = {"DRAFT": {"CALCULATED"}, "CALCULATED": {"CALCULATED", "APPROVED"},
               "APPROVED": {"PROCESSED"}, "PROCESSED": {"PAID"}, "PAID": set()}
ADJ_TYPES = {"BONUS", "INCENTIVE", "DEDUCTION", "REIMBURSEMENT", "OTHER"}


class PayrollError(Exception):
    def __init__(self, code: str, status: int = 400, message: str | None = None, details: dict | None = None):
        self.code, self.status, self.message, self.details = code, status, message or code, details or {}


def _rnd(v: Decimal, policy: Policy) -> Decimal:
    return v.quantize(D("1") if policy.rounding == "nearest_rupee" else D("0.01"), rounding=ROUND_HALF_UP)


def _d(v) -> Decimal:
    return v if isinstance(v, Decimal) else D(str(v or 0))


def compute_payroll(profile, days: list[DayResult], adjustments: list[tuple[str, Decimal]], policy: Policy) -> dict:
    """profile: object with salary fields. days: one DayResult per date in the period."""
    st = [d.status for d in days]
    present = sum(1 for s in st if s in ("PRESENT", "LATE"))
    half = st.count("HALF_DAY")
    absent = st.count("ABSENT")
    paid_leave = sum(1 for d in days if d.status == "ON_LEAVE" and d.leave_paid)
    unpaid_leave = sum(1 for d in days if d.status == "ON_LEAVE" and not d.leave_paid)
    off_days = st.count("HOLIDAY") + st.count("WEEK_OFF")
    pending = st.count("FUTURE") + st.count("NOT_ARRIVED")
    working_days = len(days) - off_days
    ot_min = sum(d.overtime_minutes for d in days)
    reg_min = sum(d.worked_minutes - d.overtime_minutes for d in days)

    basic, hra = _d(profile.basic_salary), _d(profile.hra)
    allowances = sum((_d(getattr(profile, k)) for k in
                      ("transport_allowance", "medical_allowance", "special_allowance", "other_allowance")), D(0))
    fixed = basic + hra + allowances

    divisor = {"profile": D(str(profile.working_days_per_month)), "calendar_days": D(len(days)),
               "period_working_days": D(working_days)}[policy.working_days_basis]
    if divisor <= 0:
        divisor = D(1)
    base = fixed if policy.deduction_base == "fixed_gross" else basic
    per_day = base / divisor
    lop_days = D(unpaid_leave) + (D(absent) if policy.deduct_absent_days else D(0)) \
        + D(half) * D(str(policy.half_day_deduction_factor))
    lop = min(per_day * lop_days, base)

    ot_hours = D(ot_min) / D(60)
    ot_pay = ot_hours * _d(profile.overtime_rate) * D(str(policy.overtime_multiplier))

    bonus = sum((a for t, a in adjustments if t in ("BONUS", "INCENTIVE") or (t == "OTHER" and a > 0)), D(0))
    extra_ded = sum((a for t, a in adjustments if t == "DEDUCTION"), D(0)) \
        + sum((-a for t, a in adjustments if t == "OTHER" and a < 0), D(0))
    reimb = sum((a for t, a in adjustments if t == "REIMBURSEMENT"), D(0))

    r = lambda v: _rnd(v, policy)  # noqa: E731
    basic_r, hra_r, allow_r = r(basic), r(hra), r(allowances)
    bonus_r, ot_r = r(bonus), r(ot_pay)
    gross = basic_r + hra_r + allow_r + bonus_r + ot_r

    pf = esi = D(0)
    if profile.pf_enabled and policy.pf_rate_percent:
        wage = basic if policy.pf_wage_basis == "basic" else fixed
        if policy.pf_wage_ceiling is not None:
            wage = min(wage, D(str(policy.pf_wage_ceiling)))
        pf = wage * D(str(policy.pf_rate_percent)) / 100
    if profile.esi_enabled and policy.esi_rate_percent:
        wage = gross if policy.esi_wage_basis == "gross" else fixed
        if policy.esi_gross_ceiling is None or fixed <= D(str(policy.esi_gross_ceiling)):
            esi = wage * D(str(policy.esi_rate_percent)) / 100
    pf_r, esi_r = r(pf), r(esi)
    pt_r = r(_d(profile.professional_tax))
    other_r = r(_d(profile.other_fixed_deduction) + extra_ded)
    lop_r = r(lop)
    total_ded = pf_r + esi_r + pt_r + other_r + lop_r
    reimb_r = r(reimb)
    net = gross - total_ded + reimb_r

    return {
        "attendance_days": float(working_days), "present_days": float(present), "absent_days": float(absent),
        "half_days": float(half), "leave_days": float(paid_leave + unpaid_leave), "holiday_days": float(off_days),
        "regular_hours": round(reg_min / 60, 2), "overtime_hours": round(ot_min / 60, 2),
        "late_count": sum(1 for d in days if d.late_minutes > 0),
        "early_checkout_count": sum(1 for d in days if d.early_minutes > 0),
        "missing_checkout_days": sum(1 for d in days if d.incomplete),
        "basic_salary": basic_r, "hra": hra_r, "allowances": allow_r, "bonus": bonus_r, "overtime_pay": ot_r,
        "gross_salary": gross, "pf_deduction": pf_r, "esi_deduction": esi_r, "professional_tax": pt_r,
        "other_deductions": other_r, "unpaid_leave_deduction": lop_r, "total_deductions": total_ded,
        "reimbursement": reimb_r, "net_salary": net,
        "breakdown": {
            "fixed_monthly": float(fixed), "salary_divisor": float(divisor), "divisor_basis": policy.working_days_basis,
            "deduction_base": policy.deduction_base, "per_day_rate": float(round(per_day, 4)),
            "lop_days": float(lop_days), "absent_days": absent, "half_days": half,
            "unpaid_leave_days": unpaid_leave, "paid_leave_days": paid_leave, "pending_days": pending,
            "overtime_rate": float(_d(profile.overtime_rate)), "overtime_multiplier": policy.overtime_multiplier,
            "negative_net": net < 0, "policy": policy.model_dump(),
        },
    }


MONEY_FIELDS = ["basic_salary", "hra", "allowances", "bonus", "overtime_pay", "gross_salary", "pf_deduction",
                "esi_deduction", "professional_tax", "other_deductions", "unpaid_leave_deduction",
                "total_deductions", "reimbursement", "net_salary"]


class PayrollService:
    def __init__(self, settings: Settings):
        self.s = settings

    # ---------- periods ----------
    def create_period(self, db: Session, year: int, month: int, actor: str) -> PayrollPeriod:
        if not (1 <= month <= 12 and 2000 <= year <= 2100):
            raise PayrollError("invalid_period", 422)
        if db.scalar(select(PayrollPeriod).where(PayrollPeriod.period_year == year, PayrollPeriod.period_month == month)):
            raise PayrollError("period_exists", 409)
        last = calendar.monthrange(year, month)[1]
        p = PayrollPeriod(period_year=year, period_month=month, start_date=date(year, month, 1),
                          end_date=date(year, month, last), status="DRAFT")
        db.add(p)
        db.flush()
        self._audit(db, p.id, None, "PERIOD_CREATED", actor, None, {"year": year, "month": month})
        db.commit()
        return p

    def get_period(self, db: Session, period_id: int) -> PayrollPeriod:
        p = db.get(PayrollPeriod, period_id)
        if not p:
            raise PayrollError("period_not_found", 404)
        return p

    @staticmethod
    def _audit(db, period_id, record_id, action, actor, old, new):
        db.add(PayrollAudit(payroll_period_id=period_id, payroll_record_id=record_id, action=action,
                            actor=actor, old_value=old, new_value=new))

    # ---------- calculate (idempotent upsert, only before approval) ----------
    def calculate(self, db: Session, period_id: int, actor: str) -> dict:
        p = self.get_period(db, period_id)
        if "CALCULATED" not in TRANSITIONS[p.status]:
            raise PayrollError("period_locked", 409, f"Payroll is {p.status}; it can no longer be recalculated.")
        try:
            emps = list(db.scalars(select(Employee).where(Employee.is_active.is_(True)).order_by(Employee.employee_code)))
            calc = AttendanceCalcService(db, self.s)
            day_map = calc.compute_range([e.id for e in emps], p.start_date, p.end_date)
            created = updated = 0
            skipped: list[str] = []
            for e in emps:
                prof = db.scalars(select(SalaryProfile).where(
                    SalaryProfile.employee_id == e.id, SalaryProfile.effective_from <= p.end_date)
                    .order_by(SalaryProfile.effective_from.desc())).first()
                if prof is None:
                    skipped.append(e.employee_code)
                    continue
                rec = db.scalar(select(PayrollRecord).where(
                    PayrollRecord.payroll_period_id == p.id, PayrollRecord.employee_id == e.id))
                adjs = []
                if rec:
                    adjs = [(a.type, _d(a.amount)) for a in db.scalars(
                        select(PayrollAdjustment).where(PayrollAdjustment.payroll_record_id == rec.id))]
                res = compute_payroll(prof, list(day_map[e.id].values()), adjs, calc.policy)
                if rec is None:
                    rec = PayrollRecord(payroll_period_id=p.id, employee_id=e.id)
                    db.add(rec)
                    created += 1
                else:
                    updated += 1
                for k, v in res.items():
                    setattr(rec, k, v)
                rec.status = "CALCULATED"
            p.status, p.calculated_by, p.calculated_at = "CALCULATED", actor, now_local(self.s.TIMEZONE)
            db.flush()
            totals = self.totals(db, p.id)
            self._audit(db, p.id, None, "CALCULATED", actor, None,
                        {"created": created, "updated": updated, "skipped_no_salary_profile": skipped, **totals})
            db.commit()
        except Exception:
            db.rollback()
            raise
        return {"period_id": p.id, "status": p.status, "created": created, "updated": updated,
                "skipped_no_salary_profile": skipped, "totals": totals}

    # ---------- workflow ----------
    def transition(self, db: Session, period_id: int, target: str, actor: str) -> PayrollPeriod:
        p = self.get_period(db, period_id)
        if target not in TRANSITIONS[p.status]:
            raise PayrollError("invalid_transition", 409, f"Cannot go from {p.status} to {target}.",
                               {"from": p.status, "to": target})
        n = db.query(PayrollRecord).filter_by(payroll_period_id=p.id).count()
        if n == 0:
            raise PayrollError("no_payroll_records", 409, "Calculate payroll first.")
        now = now_local(self.s.TIMEZONE)
        old = p.status
        p.status = target
        if target == "APPROVED":
            p.approved_by, p.approved_at = actor, now
        elif target == "PROCESSED":
            p.processed_by, p.processed_at = actor, now
        elif target == "PAID":
            p.paid_at = now
        for rec in db.scalars(select(PayrollRecord).where(PayrollRecord.payroll_period_id == p.id)):
            rec.status = target
        self._audit(db, p.id, None, target, actor, {"status": old}, {"status": target, **self.totals(db, p.id)})
        db.commit()
        return p

    def add_adjustment(self, db: Session, record_id: int, typ: str, description: str, amount, actor: str):
        rec = db.get(PayrollRecord, record_id)
        if not rec:
            raise PayrollError("record_not_found", 404)
        if typ not in ADJ_TYPES:
            raise PayrollError("invalid_adjustment_type", 422)
        if rec.period.status not in ("DRAFT", "CALCULATED"):
            raise PayrollError("period_locked", 409, "Adjustments are not allowed after approval.")
        amt = _d(amount)
        if typ != "OTHER" and amt <= 0:
            raise PayrollError("amount_must_be_positive", 422)
        adj = PayrollAdjustment(payroll_record_id=rec.id, type=typ, description=description, amount=amt, created_by=actor)
        db.add(adj)
        self._audit(db, rec.payroll_period_id, rec.id, "ADJUSTMENT_ADDED", actor, None,
                    {"type": typ, "amount": float(amt), "description": description})
        db.commit()
        return adj

    # ---------- aggregates ----------
    def totals(self, db: Session, period_id: int) -> dict:
        recs = list(db.scalars(select(PayrollRecord).where(PayrollRecord.payroll_period_id == period_id)))
        sm = lambda f: float(sum((_d(getattr(r, f)) for r in recs), D(0)))  # noqa: E731
        return {"employees": len(recs), "gross": sm("gross_salary"), "deductions": sm("total_deductions"),
                "net": sm("net_salary"), "overtime_pay": sm("overtime_pay"), "bonus": sm("bonus"),
                "unpaid_leave_deduction": sm("unpaid_leave_deduction"), "overtime_hours": sum(r.overtime_hours for r in recs)}

    def dashboard(self, db: Session) -> dict:
        periods = list(db.scalars(select(PayrollPeriod).order_by(PayrollPeriod.period_year.desc(),
                                                                 PayrollPeriod.period_month.desc()).limit(12)))
        cur = periods[0] if periods else None
        trend = [{"period": f"{p.period_year}-{p.period_month:02d}", "status": p.status, **self.totals(db, p.id)}
                 for p in reversed(periods)]
        cur_t = self.totals(db, cur.id) if cur else None
        status_counts: dict[str, int] = {}
        if cur:
            for r in db.scalars(select(PayrollRecord).where(PayrollRecord.payroll_period_id == cur.id)):
                status_counts[r.status] = status_counts.get(r.status, 0) + 1
        pending = cur_t["net"] if cur and cur.status in ("DRAFT", "CALCULATED", "APPROVED") else 0.0
        processed = cur_t["net"] if cur and cur.status in ("PROCESSED", "PAID") else 0.0
        return {"current_period": None if not cur else {"id": cur.id, "year": cur.period_year, "month": cur.period_month,
                                                        "status": cur.status},
                "totals": cur_t, "status_counts": status_counts, "pending_net": pending,
                "processed_net": processed, "trend": trend}

    @staticmethod
    def record_dict(r: PayrollRecord, with_breakdown: bool = False) -> dict:
        out = {"id": r.id, "period_id": r.payroll_period_id, "employee_code": r.employee.employee_code,
               "name": r.employee.name, "status": r.status}
        for k in ("attendance_days", "present_days", "absent_days", "half_days", "leave_days", "holiday_days",
                  "regular_hours", "overtime_hours", "late_count", "early_checkout_count", "missing_checkout_days"):
            out[k] = getattr(r, k)
        for k in MONEY_FIELDS:
            out[k] = float(getattr(r, k))
        if with_breakdown:
            out["breakdown"] = r.breakdown
        return out
