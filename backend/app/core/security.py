from fastapi import Depends, Header, HTTPException

from app.core.config import Settings, get_settings


def require_api_key(
    x_api_key: str | None = Header(default=None),
    settings: Settings = Depends(get_settings),
) -> None:
    """Optional shared-secret auth. Disabled when API_KEY is empty."""
    if settings.API_KEY and x_api_key != settings.API_KEY:
        raise HTTPException(status_code=401, detail="invalid_api_key")
