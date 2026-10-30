from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import get_settings

_settings = get_settings()
_kwargs = {"connect_args": {"check_same_thread": False}} if _settings.DATABASE_URL.startswith("sqlite") else {}
engine = create_engine(_settings.DATABASE_URL, pool_pre_ping=True, future=True, **_kwargs)
SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
