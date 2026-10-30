from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=BASE_DIR / ".env", extra="ignore")

    APP_NAME: str = "Face Attendance V3"
    DATABASE_URL: str = "postgresql+psycopg2://postgres:postgres@localhost:5432/attendance_v3"
    CORS_ORIGINS: str = "http://localhost:5173,http://127.0.0.1:5173"
    API_KEY: str = ""  # empty = auth disabled (dev only)
    TIMEZONE: str = "Asia/Kolkata"

    MODELS_DIR: Path = BASE_DIR / "models"
    MAX_UPLOAD_BYTES: int = 10 * 1024 * 1024
    MAX_IMAGE_SIDE: int = 1280

    # detection
    DETECTION_SCORE_THRESHOLD: float = 0.5
    DETECTION_NMS_THRESHOLD: float = 0.4

    # quality
    MIN_FACE_WIDTH: int = 120
    MIN_FACE_HEIGHT: int = 120
    MIN_FACE_AREA_RATIO: float = 0.04
    MIN_BLUR_SCORE: float = 12.0

    # liveness
    LIVENESS_REAL_INDEX: int = 1
    LIVENESS_THRESHOLD: float = 0.80
    LIVENESS_CROP_SCALE: float = 2.7

    # enrollment
    ENROLLMENT_TARGET: int = 15
    ENROLLMENT_TTL_SECONDS: int = 900
    DUPLICATE_SIMILARITY: float = 0.995
    MIN_CENTROID_SIMILARITY: float = 0.45
    ENROLL_MAX_CROSS_SIMILARITY: float = 0.70

    # matching
    RECOGNITION_THRESHOLD: float = 0.45
    RECOGNITION_MARGIN: float = 0.08
    RECOGNITION_SCORE_METRIC: str = "topk_mean"  # best | topk_mean | median | centroid
    RECOGNITION_TOP_K: int = 3

    # attendance
    MIN_MINUTES_BEFORE_CHECKOUT: int = 30
    EVENT_THROTTLE_SECONDS: int = 30

    @property
    def cors_list(self) -> list[str]:
        return [o.strip() for o in self.CORS_ORIGINS.split(",") if o.strip()]

    @property
    def detector_path(self) -> Path:
        return self.MODELS_DIR / "detection" / "scrfd_500m_kps.onnx"

    @property
    def liveness_path(self) -> Path:
        return self.MODELS_DIR / "liveness" / "MiniFASNetV2.onnx"

    @property
    def recognizer_path(self) -> Path:
        return self.MODELS_DIR / "recognition" / "w600k_mbf.onnx"


@lru_cache
def get_settings() -> Settings:
    return Settings()
