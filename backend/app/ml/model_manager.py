"""Loads every ONNX model ONCE at startup and fails loudly if anything is wrong."""
import logging

import numpy as np

from app.core.config import Settings
from app.ml.detector import SCRFDDetector
from app.ml.liveness import MiniFASNetLiveness
from app.ml.pipeline import FacePipeline
from app.ml.recognizer import FaceRecognizer

log = logging.getLogger("models")


class ModelManager:
    def __init__(self, settings: Settings):
        self.s = settings
        self.detector: SCRFDDetector | None = None
        self.liveness: MiniFASNetLiveness | None = None
        self.recognizer: FaceRecognizer | None = None
        self.pipeline: FacePipeline | None = None

    def load_all(self) -> None:
        for p in (self.s.detector_path, self.s.liveness_path, self.s.recognizer_path):
            if not p.exists():
                raise FileNotFoundError(f"Model file missing: {p}")
        self.detector = SCRFDDetector(
            self.s.detector_path, score_thresh=self.s.DETECTION_SCORE_THRESHOLD,
            nms_thresh=self.s.DETECTION_NMS_THRESHOLD)
        self.liveness = MiniFASNetLiveness(
            self.s.liveness_path, self.s.LIVENESS_REAL_INDEX, self.s.LIVENESS_THRESHOLD,
            self.s.LIVENESS_CROP_SCALE)
        self.recognizer = FaceRecognizer(self.s.recognizer_path)
        self._validate()
        self.pipeline = FacePipeline(self.detector, self.liveness, self.recognizer, self.s)
        log.info("All models loaded: %s", self.health())

    def _validate(self) -> None:
        """Smoke-run every model with a dummy input so shape problems surface at startup."""
        dummy = np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8)
        self.detector.detect(dummy)
        self.liveness.predict(dummy, np.array([200, 120, 440, 400], dtype=np.float32))
        emb = self.recognizer.embed(np.random.randint(0, 255, (112, 112, 3), dtype=np.uint8))
        if emb.shape != (512,):
            raise RuntimeError(f"Recognizer must output 512-D, got {emb.shape}")
        self.recognizer.dim = int(emb.shape[0])

    def health(self) -> dict:
        def io(sess):
            return {"inputs": [(i.name, i.shape) for i in sess.get_inputs()],
                    "outputs": [(o.name, o.shape) for o in sess.get_outputs()]}
        if not self.pipeline:
            return {"loaded": False}
        return {
            "loaded": True,
            "detector": io(self.detector.session),
            "liveness": {**io(self.liveness.session), "real_index": self.liveness.real_index},
            "recognizer": {**io(self.recognizer.session), "embedding_dim": self.recognizer.dim},
        }
