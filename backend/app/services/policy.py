"""Configurable attendance + payroll policy. Stored as JSON in app_settings['policy'].
Nothing statutory is assumed: PF/ESI rates default to 0 and must be configured by the company."""
from typing import Literal

from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.db.models import AppSetting


class Policy(BaseModel):
    # ---- attendance ----
    week_off_days: list[int] = Field(default=[6], description="0=Mon ... 6=Sun")
    full_day_min_hours: float = 6.0
    half_day_min_hours: float = 4.0
    overtime_threshold_minutes: int = 30
    early_checkout_threshold_minutes: int = 0
    missing_checkout_policy: Literal["assume_required", "half_day", "absent"] = "assume_required"
    # ---- payroll ----
    working_days_basis: Literal["profile", "calendar_days", "period_working_days"] = "profile"
    deduction_base: Literal["fixed_gross", "basic"] = "fixed_gross"
    deduct_absent_days: bool = True
    half_day_deduction_factor: float = 0.5
    overtime_multiplier: float = 1.0
    pf_rate_percent: float = 0.0
    pf_wage_basis: Literal["basic", "fixed_gross"] = "basic"
    pf_wage_ceiling: float | None = None
    esi_rate_percent: float = 0.0
    esi_wage_basis: Literal["gross", "fixed_gross"] = "gross"
    esi_gross_ceiling: float | None = None
    rounding: Literal["2dp", "nearest_rupee"] = "2dp"


def get_policy(db: Session) -> Policy:
    row = db.get(AppSetting, "policy")
    return Policy(**(row.value if row else {}))


def save_policy(db: Session, p: Policy) -> Policy:
    row = db.get(AppSetting, "policy")
    if row:
        row.value = p.model_dump()
    else:
        db.add(AppSetting(key="policy", value=p.model_dump()))
    db.commit()
    return p
