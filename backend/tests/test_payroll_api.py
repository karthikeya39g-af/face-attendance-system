"""End-to-end payroll/leave/shift/report/dashboard flow against SQLite with the fake ML pipeline."""
from datetime import date, datetime, time, timedelta
from zoneinfo import ZoneInfo

import pytest
from fastapi.testclient import TestClient

from tests.test_api_flow import FakeManager

TZ = ZoneInfo("Asia/Kolkata")
Y, M = 2025, 9  # Sept 2025 is entirely in the past; Sundays: 7 14 21 28


@pytest.fixture(scope="module")
def client():
    import app.main as main
    main.ModelManager = FakeManager
    with TestClient(main.app) as c:
        yield c


def seed_attendance(emp_id: int, office_id: int):
    from app.db.models import Attendance
    from app.db.session import SessionLocal
    special = {date(Y, M, 2): ("09:30", "19:30"),   # late 30m, 1h overtime
               date(Y, M, 3): ("09:00", "14:30"),   # half day + early checkout
               date(Y, M, 4): None,                  # absent
               date(Y, M, 8): None, date(Y, M, 9): None, date(Y, M, 10): None}  # leave / leave / holiday
    with SessionLocal() as db:
        d = date(Y, M, 1)
        while d.month == M:
            if d.weekday() != 6 and special.get(d, ("09:00", "18:00")) is not None:
                ci, co = special.get(d, ("09:00", "18:00"))
                mk = lambda t: datetime.combine(d, time.fromisoformat(t), tzinfo=TZ)  # noqa: E731
                db.add(Attendance(employee_id=emp_id, office_id=office_id, attendance_date=d,
                                  check_in_time=mk(ci), check_out_time=mk(co), status="CHECKED_OUT"))
            d += timedelta(days=1)
        db.commit()


def test_full_payroll_cycle(client):
    c = client
    # policy for the test (PF rate is test configuration only)
    pol = c.get("/api/settings/policy").json()
    assert pol["pf_rate_percent"] == 0.0                         # nothing statutory by default
    pol.update(pf_rate_percent=12.0, working_days_basis="profile")
    assert c.put("/api/settings/policy", json=pol).status_code == 200

    assert c.post("/api/employees", json={"employee_code": "P1", "name": "Pay Test", "office_code": "KADAP"}).status_code == 201
    emp = c.get("/api/employees/P1").json()
    from app.db.models import Employee
    from app.db.session import SessionLocal
    with SessionLocal() as db:
        e = db.query(Employee).filter_by(employee_code="P1").one()
        seed_attendance(e.id, e.office_id)

    sal = {"basic_salary": 20000, "hra": 8000, "transport_allowance": 2000, "overtime_rate": 100,
           "working_days_per_month": 30, "pf_enabled": True, "professional_tax": 200, "effective_from": "2025-01-01"}
    assert c.put("/api/employees/P1/salary-profile", json=sal).status_code == 200
    assert c.get("/api/employees/P1/salary-profile").json()["basic_salary"] == 20000

    # holiday + leaves (unpaid on 8th, paid casual on 9th); week-off defaults to Sunday
    assert c.post("/api/holidays", json={"holiday_date": "2025-09-10", "name": "Test Holiday"}).status_code == 201
    unpaid = c.post("/api/leave/requests", json={"employee_code": "P1", "leave_type": "UNPAID",
                                                 "start_date": "2025-09-08", "end_date": "2025-09-08"}).json()
    paid = c.post("/api/leave/requests", json={"employee_code": "P1", "leave_type": "CASUAL",
                                               "start_date": "2025-09-09", "end_date": "2025-09-09"}).json()
    # overlapping request is refused; pending leave does not affect payroll until approved
    assert c.post("/api/leave/requests", json={"employee_code": "P1", "leave_type": "SICK",
                                               "start_date": "2025-09-08", "end_date": "2025-09-09"}).status_code == 409
    for r in (unpaid, paid):
        assert c.post(f"/api/leave/requests/{r['id']}/approve", headers={"X-Actor": "hr"}).json()["status"] == "APPROVED"
    assert c.post(f"/api/leave/requests/{unpaid['id']}/approve").status_code == 409   # already approved

    # period workflow
    per = c.post("/api/payroll/periods", json={"year": Y, "month": M}).json()
    pid = per["id"]
    assert c.post("/api/payroll/periods", json={"year": Y, "month": M}).status_code == 409
    assert c.post(f"/api/payroll/periods/{pid}/approve").status_code == 409            # DRAFT -> APPROVED not allowed

    out = c.post(f"/api/payroll/periods/{pid}/calculate", headers={"X-Actor": "payroll1"}).json()
    assert out["status"] == "CALCULATED" and out["created"] == 1
    rec = [r for r in c.get(f"/api/payroll/records?period_id={pid}").json() if r["employee_code"] == "P1"][0]
    assert (rec["present_days"], rec["half_days"], rec["absent_days"], rec["leave_days"]) == (21, 1, 1, 2)
    assert rec["overtime_hours"] == 1.0 and rec["late_count"] == 1 and rec["early_checkout_count"] == 1
    assert rec["gross_salary"] == 30100 and rec["pf_deduction"] == 2400 and rec["unpaid_leave_deduction"] == 2500
    assert rec["total_deductions"] == 5100 and rec["net_salary"] == 25000

    # recalculation is idempotent (no duplicate rows, same numbers)
    again = c.post(f"/api/payroll/periods/{pid}/calculate").json()
    assert again["created"] == 0 and again["updated"] == 1
    assert [r for r in c.get(f"/api/payroll/records?period_id={pid}").json() if r["employee_code"] == "P1"][0]["net_salary"] == 25000

    # adjustments apply on next calculation and survive it
    rid = rec["id"]
    assert c.post("/api/payroll/adjustments", json={"payroll_record_id": rid, "type": "BONUS", "description": "Diwali", "amount": 500}).status_code == 201
    assert c.post("/api/payroll/adjustments", json={"payroll_record_id": rid, "type": "DEDUCTION", "description": "Advance", "amount": 100}).status_code == 201
    assert c.post("/api/payroll/adjustments", json={"payroll_record_id": rid, "type": "BONUS", "description": "x", "amount": -5}).status_code == 422
    c.post(f"/api/payroll/periods/{pid}/calculate")
    d = c.get(f"/api/payroll/records/{rid}").json()
    assert d["gross_salary"] == 30600 and d["total_deductions"] == 5200 and d["net_salary"] == 25400
    assert len(d["adjustments"]) == 2 and d["breakdown"]["lop_days"] == 2.5 and "policy" in d["breakdown"]

    # approve -> locked
    assert c.post(f"/api/payroll/periods/{pid}/approve", headers={"X-Actor": "boss"}).json()["status"] == "APPROVED"
    assert c.post(f"/api/payroll/periods/{pid}/calculate").status_code == 409
    assert c.post("/api/payroll/adjustments", json={"payroll_record_id": rid, "type": "BONUS", "description": "late", "amount": 1}).status_code == 409
    assert c.post(f"/api/payroll/periods/{pid}/pay").status_code == 409                 # must be PROCESSED first
    assert c.post(f"/api/payroll/periods/{pid}/process").json()["status"] == "PROCESSED"
    assert c.post(f"/api/payroll/periods/{pid}/process").status_code == 409             # idempotent guard
    assert c.post(f"/api/payroll/periods/{pid}/pay").json()["status"] == "PAID"
    assert c.post(f"/api/payroll/periods/{pid}/calculate").status_code == 409           # PAID can never go back

    detail = c.get(f"/api/payroll/periods/{pid}").json()
    acts = {a["action"]: a["actor"] for a in detail["audit"]}
    assert acts["APPROVED"] == "boss" and acts["CALCULATED"] and detail["approved_by"] == "boss"
    assert c.get("/api/payroll/employee/P1").json()["status"] == "PAID"
    assert len(c.get("/api/payroll/employee/P1/history").json()) == 1

    dash = c.get("/api/payroll/dashboard").json()
    assert dash["current_period"]["status"] in ("PAID", "DRAFT", "CALCULATED") and "trend" in dash

    # reports (real data, CSV export)
    csv = c.get(f"/api/reports/payroll?period_id={pid}&format=csv")
    assert csv.status_code == 200 and "P1" in csv.text and csv.text.startswith("period_id,employee_code")
    late = c.get("/api/reports/late?start=2025-09-01&end=2025-09-30&employee=P1").json()
    assert late["count"] == 1 and late["rows"][0][4] == "LATE"
    ot = c.get("/api/reports/overtime?start=2025-09-01&end=2025-09-30&employee=P1").json()
    assert ot["count"] == 1 and ot["rows"][0][8] == 60
    leave = c.get("/api/reports/leave?start=2025-09-01&end=2025-09-30&employee=P1").json()
    assert leave["count"] == 2
    assert c.get("/api/reports/nonsense").status_code == 404


def test_daily_dashboard_profile_and_misc(client):
    c = client
    daily = c.get("/api/attendance/daily").json()
    assert "rows" in daily and any(r["employee_code"] == "P1" for r in daily["rows"])
    assert all("status" in r and "worked_minutes" in r for r in daily["rows"])

    s = c.get("/api/dashboard/summary").json()
    assert {"employees", "today", "hours", "trend", "offices", "ai", "payroll"} <= set(s)
    assert len(s["trend"]) == 14 and s["employees"]["active"] >= 1

    p = c.get("/api/employees/P1/profile").json()
    assert p["employee"]["employee_code"] == "P1" and p["face"]["enrolled"] is False
    assert p["salary_profile"]["basic_salary"] == 20000 and p["latest_payroll"]["status"] == "PAID"

    # shifts: create, make default, assign
    sh = c.post("/api/shifts", json={"name": "Night-ish", "start_time": "10:00", "end_time": "19:00",
                                      "break_minutes": 30, "grace_minutes": 10, "required_hours": 8.5}).json()
    assert c.post("/api/shifts/assign", json={"employee_code": "P1", "shift_id": sh["id"], "effective_from": "2025-10-01"}).status_code == 201
    assert any(a["employee_code"] == "P1" for a in c.get("/api/shifts/assignments").json())
    assert c.post("/api/shifts", json={"name": "Night-ish", "start_time": "10:00", "end_time": "19:00"}).status_code == 409

    # offices
    assert c.post("/api/offices", json={"code": "hyd", "name": "Hyderabad"}).json()["code"] == "HYD"
    assert any(o["code"] == "HYD" for o in c.get("/api/offices").json())

    # config + structured errors
    cfg = c.get("/api/system/config").json()
    assert cfg["RECOGNITION_THRESHOLD"] == 0.45
    e = c.get("/api/employees/NOPE").json()
    assert e["success"] is False and e["error"]["code"] == "EMPLOYEE_NOT_FOUND"
    v = c.post("/api/payroll/periods", json={"year": 2025, "month": 13}).json()
    assert v["success"] is False and v["error"]["code"] == "VALIDATION_ERROR"

    # recognition now returns a face box for the UI overlay
    import cv2, numpy as np
    img = np.zeros((64, 64, 3), dtype=np.uint8); img[0, 0] = (99, 0, 0)       # fake spoof marker
    ok, buf = cv2.imencode(".png", img)
    r = c.post("/api/face/recognize", files={"file": ("a.png", buf.tobytes(), "image/png")}).json()
    assert r["bbox"] and r["image_size"] == [64, 64]

    # restore default policy so other tests/data are unaffected
    pol = c.get("/api/settings/policy").json(); pol["pf_rate_percent"] = 0.0
    c.put("/api/settings/policy", json=pol)
