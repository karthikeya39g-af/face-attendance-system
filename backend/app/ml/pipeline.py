"""Camera frame -> detection -> quality -> liveness -> alignment -> embedding."""
from dataclasses import dataclass, field

import numpy as np

from app.core.config import Settings
from app.ml.alignment import align_face
from app.ml.detector import Detection, SCRFDDetector
from app.ml.liveness import MiniFASNetLiveness
from app.ml.recognizer import FaceRecognizer
from app.utils.quality import check_quality


@dataclass
class FaceAnalysis:
    ok: bool
    reason: str | None = None
    face_count: int = 0
    detection: Detection | None = None
    quality: dict = field(default_factory=dict)
    liveness: dict | None = None
    embedding: np.ndarray | None = None


class FacePipeline:
    def __init__(self, detector: SCRFDDetector, liveness: MiniFASNetLiveness,
                 recognizer: FaceRecognizer, settings: Settings):
        self.detector, self.liveness, self.recognizer, self.s = detector, liveness, recognizer, settings

    def analyze(self, img: np.ndarray) -> FaceAnalysis:
        dets = self.detector.detect(img)
        if not dets:
            return FaceAnalysis(False, "no_face_detected")
        dets.sort(key=lambda d: d.area, reverse=True)
        main = dets[0]
        # a second sizeable face means we can't be sure who is being scanned
        if len(dets) > 1 and dets[1].score >= 0.6 and dets[1].area >= 0.3 * main.area:
            return FaceAnalysis(False, "multiple_faces", len(dets), main)

        ok, reason, quality = check_quality(img, main.bbox, self.s)
        if not ok:
            return FaceAnalysis(False, reason, len(dets), main, quality)

        live = self.liveness.predict(img, main.bbox)
        if not live["is_live"]:
            return FaceAnalysis(False, "spoof_detected", len(dets), main, quality, live)

        aligned = align_face(img, main.kps)
        emb = self.recognizer.embed(aligned)
        return FaceAnalysis(True, None, len(dets), main, quality, live, emb)
