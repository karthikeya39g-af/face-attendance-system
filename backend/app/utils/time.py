from datetime import date, datetime
from zoneinfo import ZoneInfo


def now_local(tz: str) -> datetime:
    return datetime.now(ZoneInfo(tz))


def today_local(tz: str) -> date:
    return now_local(tz).date()


def as_aware(dt: datetime, tz: str) -> datetime:
    return dt if dt.tzinfo else dt.replace(tzinfo=ZoneInfo(tz))


def to_local(dt: datetime, tz: str) -> datetime:
    """Naive datetimes are assumed local; aware ones are converted to the configured timezone."""
    z = ZoneInfo(tz)
    return dt.replace(tzinfo=z) if dt.tzinfo is None else dt.astimezone(z)
