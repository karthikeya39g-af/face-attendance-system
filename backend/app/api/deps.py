from fastapi import Header, HTTPException, Request, UploadFile

from app.core.config import get_settings


def models(request: Request):
    return request.app.state.models


def recognition_service(request: Request):
    return request.app.state.recognition


def enrollment_service(request: Request):
    return request.app.state.enrollment


def read_upload(file: UploadFile) -> bytes:
    data = file.file.read(get_settings().MAX_UPLOAD_BYTES + 1)
    if len(data) > get_settings().MAX_UPLOAD_BYTES:
        raise HTTPException(413, "image_too_large")
    return data


def actor(x_actor: str | None = Header(default=None)) -> str:
    """Who is performing an audited action (no user system yet; optional X-Actor header)."""
    return (x_actor or "admin")[:64]
