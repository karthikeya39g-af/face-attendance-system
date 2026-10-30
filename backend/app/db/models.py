from datetime import date, datetime, time
from decimal import Decimal

from sqlalchemy import (JSON, Boolean, Date, DateTime, Float, ForeignKey, Integer, LargeBinary, Numeric,
                        String, Text, Time, UniqueConstraint, func)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class Office(Base):
    __tablename__ = "offices"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    code: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(128))
    employees: Mapped[list["Employee"]] = relationship(back_populates="office")


class Employee(Base):
    __tablename__ = "employees"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    employee_code: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(128))
    office_id: Mapped[int] = mapped_column(ForeignKey("offices.id"), index=True)
    department: Mapped[str | None] = mapped_column(String(64), nullable=True)
    designation: Mapped[str | None] = mapped_column(String(64), nullable=True)
    email: Mapped[str | None] = mapped_column(String(128), nullable=True)
    phone: Mapped[str | None] = mapped_column(String(32), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    office: Mapped[Office] = relationship(back_populates="employees")
    embeddings: Mapped[list["FaceEmbedding"]] = relationship(
        back_populates="employee", cascade="all, delete-orphan")


class FaceEmbedding(Base):
    __tablename__ = "face_embeddings"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    employee_id: Mapped[int] = mapped_column(ForeignKey("employees.id", ondelete="CASCADE"), index=True)
    embedding: Mapped[bytes] = mapped_column(LargeBinary)  # 512 x float32 = 2048 bytes
    model_name: Mapped[str] = mapped_column(String(64), default="w600k_mbf")
    blur_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    liveness_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    employee: Mapped[Employee] = relationship(back_populates="embeddings")


class Attendance(Base):
    __tablename__ = "attendance"
    __table_args__ = (UniqueConstraint("employee_id", "attendance_date", name="uq_employee_day"),)
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    employee_id: Mapped[int] = mapped_column(ForeignKey("employees.id", ondelete="CASCADE"), index=True)
    office_id: Mapped[int] = mapped_column(ForeignKey("offices.id"))
    attendance_date: Mapped[date] = mapped_column(Date, index=True)
    check_in_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    check_out_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    check_in_similarity: Mapped[float | None] = mapped_column(Float, nullable=True)
    check_out_similarity: Mapped[float | None] = mapped_column(Float, nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="CHECKED_IN")

    employee: Mapped[Employee] = relationship()


class AttendanceEvent(Base):
    __tablename__ = "attendance_events"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    employee_id: Mapped[int | None] = mapped_column(
        ForeignKey("employees.id", ondelete="SET NULL"), nullable=True, index=True)
    office_id: Mapped[int | None] = mapped_column(ForeignKey("offices.id"), nullable=True)
    event_type: Mapped[str] = mapped_column(String(40), index=True)
    similarity: Mapped[float | None] = mapped_column(Float, nullable=True)
    details: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), index=True)


# ======================= payroll / leave / shifts (additive tables) =======================
Money = Numeric(12, 2)
ZERO = Decimal("0")


class AppSetting(Base):
    """Key/value JSON settings (attendance + payroll policy lives under key 'policy')."""
    __tablename__ = "app_settings"
    key: Mapped[str] = mapped_column(String(64), primary_key=True)
    value: Mapped[dict] = mapped_column(JSON)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class WorkShift(Base):
    __tablename__ = "work_shifts"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(64), unique=True)
    start_time: Mapped[time] = mapped_column(Time)
    end_time: Mapped[time] = mapped_column(Time)
    break_minutes: Mapped[int] = mapped_column(Integer, default=60)
    grace_minutes: Mapped[int] = mapped_column(Integer, default=15)
    required_hours: Mapped[float] = mapped_column(Float, default=8.0)
    is_default: Mapped[bool] = mapped_column(Boolean, default=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class EmployeeShift(Base):
    __tablename__ = "employee_shifts"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    employee_id: Mapped[int] = mapped_column(ForeignKey("employees.id", ondelete="CASCADE"), index=True)
    shift_id: Mapped[int] = mapped_column(ForeignKey("work_shifts.id"))
    effective_from: Mapped[date] = mapped_column(Date)
    effective_to: Mapped[date | None] = mapped_column(Date, nullable=True)
    shift: Mapped[WorkShift] = relationship()


class Holiday(Base):
    __tablename__ = "holidays"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    holiday_date: Mapped[date] = mapped_column(Date, unique=True, index=True)
    name: Mapped[str] = mapped_column(String(128))


class LeaveType(Base):
    __tablename__ = "leave_types"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    code: Mapped[str] = mapped_column(String(16), unique=True)
    name: Mapped[str] = mapped_column(String(64))
    is_paid: Mapped[bool] = mapped_column(Boolean, default=True)


class LeaveRequest(Base):
    __tablename__ = "leave_requests"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    employee_id: Mapped[int] = mapped_column(ForeignKey("employees.id", ondelete="CASCADE"), index=True)
    leave_type_id: Mapped[int] = mapped_column(ForeignKey("leave_types.id"))
    start_date: Mapped[date] = mapped_column(Date, index=True)
    end_date: Mapped[date] = mapped_column(Date)
    days: Mapped[float] = mapped_column(Float)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(String(16), default="PENDING", index=True)
    approved_by: Mapped[str | None] = mapped_column(String(64), nullable=True)
    decided_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    employee: Mapped[Employee] = relationship()
    leave_type: Mapped[LeaveType] = relationship()


class SalaryProfile(Base):
    __tablename__ = "salary_profiles"
    __table_args__ = (UniqueConstraint("employee_id", "effective_from", name="uq_salary_emp_from"),)
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    employee_id: Mapped[int] = mapped_column(ForeignKey("employees.id", ondelete="CASCADE"), index=True)
    basic_salary: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    hra: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    transport_allowance: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    medical_allowance: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    special_allowance: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    other_allowance: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    overtime_rate: Mapped[Decimal] = mapped_column(Money, default=ZERO)  # amount per overtime hour
    working_hours_per_day: Mapped[float] = mapped_column(Float, default=8.0)
    working_days_per_month: Mapped[float] = mapped_column(Float, default=26.0)
    pf_enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    esi_enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    professional_tax: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    other_fixed_deduction: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    effective_from: Mapped[date] = mapped_column(Date)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class PayrollPeriod(Base):
    __tablename__ = "payroll_periods"
    __table_args__ = (UniqueConstraint("period_year", "period_month", name="uq_payroll_period"),)
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    period_year: Mapped[int] = mapped_column(Integer)
    period_month: Mapped[int] = mapped_column(Integer)
    start_date: Mapped[date] = mapped_column(Date)
    end_date: Mapped[date] = mapped_column(Date)
    status: Mapped[str] = mapped_column(String(16), default="DRAFT", index=True)
    calculated_by: Mapped[str | None] = mapped_column(String(64), nullable=True)
    calculated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    approved_by: Mapped[str | None] = mapped_column(String(64), nullable=True)
    approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    processed_by: Mapped[str | None] = mapped_column(String(64), nullable=True)
    processed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    paid_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class PayrollRecord(Base):
    __tablename__ = "payroll_records"
    __table_args__ = (UniqueConstraint("payroll_period_id", "employee_id", name="uq_payroll_emp_period"),)
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    payroll_period_id: Mapped[int] = mapped_column(ForeignKey("payroll_periods.id", ondelete="CASCADE"), index=True)
    employee_id: Mapped[int] = mapped_column(ForeignKey("employees.id", ondelete="CASCADE"), index=True)
    attendance_days: Mapped[float] = mapped_column(Float, default=0)
    present_days: Mapped[float] = mapped_column(Float, default=0)
    absent_days: Mapped[float] = mapped_column(Float, default=0)
    half_days: Mapped[float] = mapped_column(Float, default=0)
    leave_days: Mapped[float] = mapped_column(Float, default=0)
    holiday_days: Mapped[float] = mapped_column(Float, default=0)
    regular_hours: Mapped[float] = mapped_column(Float, default=0)
    overtime_hours: Mapped[float] = mapped_column(Float, default=0)
    late_count: Mapped[int] = mapped_column(Integer, default=0)
    early_checkout_count: Mapped[int] = mapped_column(Integer, default=0)
    missing_checkout_days: Mapped[int] = mapped_column(Integer, default=0)
    basic_salary: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    hra: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    allowances: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    bonus: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    overtime_pay: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    gross_salary: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    pf_deduction: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    esi_deduction: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    professional_tax: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    other_deductions: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    unpaid_leave_deduction: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    total_deductions: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    reimbursement: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    net_salary: Mapped[Decimal] = mapped_column(Money, default=ZERO)
    breakdown: Mapped[dict | None] = mapped_column(JSON, nullable=True)  # full calculation trail + policy snapshot
    status: Mapped[str] = mapped_column(String(16), default="CALCULATED")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    employee: Mapped[Employee] = relationship()
    period: Mapped[PayrollPeriod] = relationship()


class PayrollAdjustment(Base):
    __tablename__ = "payroll_adjustments"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    payroll_record_id: Mapped[int] = mapped_column(ForeignKey("payroll_records.id", ondelete="CASCADE"), index=True)
    type: Mapped[str] = mapped_column(String(16))  # BONUS INCENTIVE DEDUCTION REIMBURSEMENT OTHER
    description: Mapped[str] = mapped_column(String(255))
    amount: Mapped[Decimal] = mapped_column(Money)
    created_by: Mapped[str | None] = mapped_column(String(64), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class PayrollAudit(Base):
    __tablename__ = "payroll_audit_log"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    payroll_period_id: Mapped[int] = mapped_column(ForeignKey("payroll_periods.id", ondelete="CASCADE"), index=True)
    payroll_record_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    action: Mapped[str] = mapped_column(String(32))
    actor: Mapped[str] = mapped_column(String(64))
    old_value: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    new_value: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
