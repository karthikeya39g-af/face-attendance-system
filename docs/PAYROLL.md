# Payroll
Flow: DRAFT -> CALCULATED -> APPROVED -> PROCESSED -> PAID. Invalid transitions return 409. After APPROVED nothing can be recalculated or adjusted.
`Calculate` is an idempotent upsert (same inputs => same numbers); adjustments survive recalculation.
```
fixed        = basic + HRA + allowances
per_day      = (fixed or basic) / divisor      divisor: employee working days | calendar days | period working days
lop_days     = unpaid leave + absent days (if enabled) + half days x factor
unpaid_leave_deduction = min(per_day x lop_days, base)
overtime_pay = overtime hours x overtime_rate x multiplier
gross        = fixed + overtime_pay + bonus
deductions   = PF + ESI + professional tax + other fixed/adjustment deductions + unpaid_leave_deduction
net          = gross - deductions + reimbursements
```
PF/ESI rates, wage bases and ceilings are POLICY values that default to 0. Nothing statutory is assumed; confirm with your payroll advisor.
Adjustment types: BONUS, INCENTIVE (earnings), DEDUCTION, REIMBURSEMENT (added to net), OTHER (signed). Every record stores a full `breakdown` incl. a policy snapshot.
Audit: `payroll_audit_log` (action, actor, old/new). There is no login yet, so "actor" is the optional `X-Actor` header (default "admin") and is NOT verified.
