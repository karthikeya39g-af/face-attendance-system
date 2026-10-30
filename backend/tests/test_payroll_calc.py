"""Pure-function tests: daily classification + payroll maths (no DB, no server)."""
from datetime import date, datetime, time
from decimal import Decimal
from types import SimpleNamespace
from zoneinfo import ZoneInfo

from app.services.attendance_calc import DayResult, LeaveInfo, ShiftInfo, compute_day
from app.services.payroll_service import compute_payroll
from app.services.policy import Policy

TZ = ZoneInfo("Asia/Kolkata")
SHIFT = ShiftInfo("General", time(9, 0), time(18, 0), 60, 15, 480)
NOW = datetime(2026, 10, 20, 12, 0, tzinfo=TZ)
DAY = date(2026, 10, 5)  # a Monday in the past
P = Policy()


def rec(ci: str | None, co: str | None, day=DAY):
    f = lambda t: datetime.combine(day, time.fromisoformat(t), tzinfo=TZ) if t else None  # noqa: E731
    return SimpleNamespace(check_in_time=f(ci), check_out_time=f(co))


def day(r, **kw):
    a = dict(shift=SHIFT, leave=None, is_holiday=False, is_weekoff=False, policy=P, now=NOW)
    a.update(kw)
    return compute_day(DAY, r, a["shift"], a["leave"], a["is_holiday"], a["is_weekoff"], a["policy"], a["now"])


def test_full_day_present_no_overtime():
    r = day(rec("09:00", "18:00"))
    assert (r.status, r.worked_minutes, r.late_minutes, r.early_minutes, r.overtime_minutes) == ("PRESENT", 480, 0, 0, 0)


def test_grace_period_not_late_but_16_min_is_late():
    assert day(rec("09:15", "18:00")).late_minutes == 0
    r = day(rec("09:16", "18:00"))
    assert r.status == "LATE" and r.late_minutes == 16


def test_overtime_needs_threshold():
    assert day(rec("09:00", "18:20")).overtime_minutes == 0      # 20 < 30
    assert day(rec("09:00", "18:30")).overtime_minutes == 30


def test_early_checkout_and_half_day_and_short_hours():
    r = day(rec("09:00", "14:30"))
    assert r.status == "HALF_DAY" and r.early_minutes == 210
    s = day(rec("09:00", "12:00"))   # 2h worked
    assert s.status == "ABSENT" and s.short_hours


def test_no_record_cases():
    assert day(None).status == "ABSENT"
    assert day(None, is_holiday=True).status == "HOLIDAY"
    assert day(None, is_weekoff=True).status == "WEEK_OFF"
    assert day(None, leave=LeaveInfo("CASUAL", True)).status == "ON_LEAVE"
    assert day(None, is_holiday=True, leave=LeaveInfo("CASUAL", True)).status == "HOLIDAY"


def test_today_before_shift_is_not_absent_and_open_checkin_is_working():
    morning = datetime.combine(DAY, time(8, 0), tzinfo=TZ)
    assert day(None, now=morning).status == "NOT_ARRIVED"
    noon = datetime.combine(DAY, time(12, 0), tzinfo=TZ)
    r = day(rec("09:00", None), now=noon)
    assert r.currently_working and r.status == "PRESENT" and r.worked_minutes == 120


def test_missing_checkout_policies():
    assert day(rec("09:00", None)).worked_minutes == 480        # assume_required (default)
    assert day(rec("09:00", None), policy=Policy(missing_checkout_policy="half_day")).status == "HALF_DAY"
    r = day(rec("09:00", None), policy=Policy(missing_checkout_policy="absent"))
    assert r.status == "ABSENT" and r.incomplete


def mk(status="PRESENT", worked=480, ot=0, late=0, early=0, paid=None, incomplete=False):
    return DayResult(date=DAY, status=status, checked_in=status in ("PRESENT", "LATE", "HALF_DAY"), worked_minutes=worked,
                     overtime_minutes=ot, late_minutes=late, early_minutes=early, leave_paid=paid, incomplete=incomplete)


PROFILE = SimpleNamespace(basic_salary=20000, hra=8000, transport_allowance=2000, medical_allowance=0,
                          special_allowance=0, other_allowance=0, overtime_rate=100, working_days_per_month=30,
                          pf_enabled=True, esi_enabled=False, professional_tax=200, other_fixed_deduction=0)


def month():
    days = [mk() for _ in range(25)]
    days += [mk("WEEK_OFF", 0) for _ in range(4)] + [mk("HOLIDAY", 0)]
    days[0] = mk("LATE", 540, ot=60, late=30)
    days[1] = mk("HALF_DAY", 270, early=210)
    days[2] = mk("ABSENT", 0)
    days[3] = mk("ON_LEAVE", 0, paid=False)
    days[4] = mk("ON_LEAVE", 0, paid=True)
    return days


def test_payroll_hand_calculation():
    pol = Policy(pf_rate_percent=12.0)
    r = compute_payroll(PROFILE, month(), [], pol)
    assert r["present_days"] == 21 and r["half_days"] == 1 and r["absent_days"] == 1 and r["leave_days"] == 2
    assert r["attendance_days"] == 25 and r["holiday_days"] == 5
    assert r["overtime_hours"] == 1.0 and r["late_count"] == 1 and r["early_checkout_count"] == 1
    assert r["unpaid_leave_deduction"] == Decimal("2500.00")      # (1 unpaid + 1 absent + 0.5 half) * 1000
    assert r["gross_salary"] == Decimal("30100.00")               # 30000 fixed + 1h * 100
    assert r["pf_deduction"] == Decimal("2400.00")                # 12% of basic (test config, not legal advice)
    assert r["total_deductions"] == Decimal("5100.00") and r["net_salary"] == Decimal("25000.00")


def test_payroll_is_deterministic_and_has_breakdown():
    a = compute_payroll(PROFILE, month(), [], Policy(pf_rate_percent=12.0))
    b = compute_payroll(PROFILE, month(), [], Policy(pf_rate_percent=12.0))
    assert a == b and a["breakdown"]["lop_days"] == 2.5 and a["breakdown"]["policy"]["pf_rate_percent"] == 12.0


def test_adjustments_bonus_deduction_reimbursement():
    adj = [("BONUS", Decimal("500")), ("DEDUCTION", Decimal("100")), ("REIMBURSEMENT", Decimal("50")),
           ("OTHER", Decimal("-30")), ("OTHER", Decimal("20"))]
    r = compute_payroll(PROFILE, month(), adj, Policy(pf_rate_percent=12.0))
    assert r["bonus"] == Decimal("520.00") and r["other_deductions"] == Decimal("130.00")
    assert r["gross_salary"] == Decimal("30620.00") and r["net_salary"] == Decimal("30620") - Decimal("5230") + Decimal("50")


def test_statutory_rates_default_to_zero_and_ceilings():
    r = compute_payroll(PROFILE, month(), [], Policy())            # nothing assumed
    assert r["pf_deduction"] == 0 and r["esi_deduction"] == 0
    prof = SimpleNamespace(**{**PROFILE.__dict__, "esi_enabled": True})
    over = compute_payroll(prof, month(), [], Policy(esi_rate_percent=1.0, esi_gross_ceiling=25000))
    assert over["esi_deduction"] == 0                              # fixed 30000 above ceiling
    under = compute_payroll(prof, month(), [], Policy(esi_rate_percent=1.0, esi_gross_ceiling=40000))
    assert under["esi_deduction"] == Decimal("301.00")             # 1% of gross 30100


def test_divisor_bases_and_rounding():
    cal = compute_payroll(PROFILE, month(), [], Policy(working_days_basis="calendar_days"))
    assert cal["breakdown"]["salary_divisor"] == 30
    pw = compute_payroll(PROFILE, month(), [], Policy(working_days_basis="period_working_days"))
    assert pw["breakdown"]["salary_divisor"] == 25 and pw["unpaid_leave_deduction"] == Decimal("3000.00")
    odd = SimpleNamespace(**{**PROFILE.__dict__, "working_days_per_month": 26})
    rup = compute_payroll(odd, month(), [], Policy(rounding="nearest_rupee"))
    assert rup["unpaid_leave_deduction"] == Decimal("2885")        # 30000/26*2.5 = 2884.6 -> 2885


def test_absent_not_deducted_when_policy_off_and_lop_capped():
    r = compute_payroll(PROFILE, month(), [], Policy(deduct_absent_days=False))
    assert r["unpaid_leave_deduction"] == Decimal("1500.00")       # 1 unpaid + 0.5 half
    all_absent = [mk("ABSENT", 0) for _ in range(30)]
    cap = compute_payroll(PROFILE, all_absent, [], Policy())
    assert cap["unpaid_leave_deduction"] == Decimal("30000.00")    # never more than the fixed salary
