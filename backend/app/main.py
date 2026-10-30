import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.api import (admin, attendance, dashboard, employees, enrollment, health, leave, offices, payroll,
                     recognition, reports, settings as settings_api, shifts)
from app.core.config import get_settings
from app.core.logging import setup_logging
from app.db.init_db import init_db
from app.db.session import SessionLocal, engine
from app.ml.matcher import GalleryMatcher
from app.ml.model_manager import ModelManager
from app.repositories.embedding_repository import EmbeddingRepository
from app.services.attendance_service import AttendanceService
from app.services.enrollment_service import EnrollmentService
from app.services.recognition_service import RecognitionService

setup_logging()
log = logging.getLogger("app")
settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db(engine)

    models = ModelManager(settings)
    models.load_all()  # raises -> app refuses to start if a model is missing/invalid

    matcher = GalleryMatcher(settings.RECOGNITION_THRESHOLD, settings.RECOGNITION_MARGIN,
                             settings.RECOGNITION_SCORE_METRIC, settings.RECOGNITION_TOP_K)
    with SessionLocal() as db:
        matcher.set_gallery(EmbeddingRepository(db).load_gallery())
    log.info("Gallery loaded: %d employees", len(matcher.entries))

    app.state.models = models
    app.state.matcher = matcher
    app.state.enrollment = EnrollmentService(models, matcher, settings)
    app.state.recognition = RecognitionService(models, matcher, AttendanceService(settings), settings)
    yield


app = FastAPI(title=settings.APP_NAME, version="3.0.0", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=settings.cors_list, allow_credentials=True,
                   allow_methods=["*"], allow_headers=["*"])

for r in (health.router, employees.router, enrollment.router, recognition.router, attendance.router,
          admin.router, payroll.router, leave.router, shifts.router, settings_api.router, offices.router,
          reports.router, dashboard.router):
    app.include_router(r)


# Structured errors: {"success": false, "error": {code, message, details}} (+ legacy "detail" kept for clients)
@app.exception_handler(StarletteHTTPException)
async def http_error(request: Request, exc: StarletteHTTPException):
    d = exc.detail
    code = d if isinstance(d, str) else (d.get("error") if isinstance(d, dict) else None) or f"HTTP_{exc.status_code}"
    msg = d.get("message") if isinstance(d, dict) and d.get("message") else str(code).replace("_", " ").capitalize()
    details = {k: v for k, v in d.items() if k not in ("error", "message")} if isinstance(d, dict) else {}
    return JSONResponse(status_code=exc.status_code, content={
        "success": False, "error": {"code": str(code).upper(), "message": msg, "details": details}, "detail": d})


@app.exception_handler(RequestValidationError)
async def validation_error(request: Request, exc: RequestValidationError):
    errs = jsonable_errors(exc)
    return JSONResponse(status_code=422, content={
        "success": False, "error": {"code": "VALIDATION_ERROR", "message": "Invalid request",
                                    "details": {"errors": errs}}, "detail": errs})


@app.exception_handler(Exception)
async def unhandled_error(request: Request, exc: Exception):
    log.exception("Unhandled error on %s %s", request.method, request.url.path)  # stack trace only in the server log
    return JSONResponse(status_code=500, content={
        "success": False, "error": {"code": "INTERNAL_ERROR", "message": "Something went wrong", "details": {}},
        "detail": "internal_error"})


def jsonable_errors(exc: RequestValidationError) -> list:
    return [{"loc": list(e.get("loc", [])), "msg": e.get("msg"), "type": e.get("type")} for e in exc.errors()]
