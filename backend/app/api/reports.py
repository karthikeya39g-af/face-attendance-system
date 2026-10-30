from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import Response
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.security import require_api_key
from app.db.session import get_db
from app.services.report_service import ReportService

router = APIRouter(prefix="/api/reports", tags=["reports"], dependencies=[Depends(require_api_key)])


@router.get("/{name}")
def report(name: str, start: date | None = None, end: date | None = None, office: str | None = None,
           employee: str | None = None, period_id: int | None = None, format: str = "json",
           db: Session = Depends(get_db), s: Settings = Depends(get_settings)):
    if name not in ReportService.NAMES:
        raise HTTPException(404, {"error": "unknown_report", "available": ReportService.NAMES})
    svc = ReportService(s)
    cols, rows = svc.build(db, name, start, end, office, employee, period_id)
    if format == "csv":
        return Response(svc.to_csv(cols, rows), media_type="text/csv",
                        headers={"Content-Disposition": f'attachment; filename="{name}_report.csv"'})
    return {"report": name, "columns": cols, "rows": rows[:5000], "count": len(rows)}
