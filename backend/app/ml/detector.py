"""SCRFD 500M KPS face detector (ONNX Runtime). Returns bbox + 5 landmarks."""
from dataclasses import dataclass

import cv2
import numpy as np
import onnxruntime as ort


@dataclass
class Detection:
    bbox: np.ndarray  # [x1, y1, x2, y2] in original image coordinates
    score: float
    kps: np.ndarray   # (5, 2): left eye, right eye, nose, left mouth, right mouth

    @property
    def area(self) -> float:
        return float((self.bbox[2] - self.bbox[0]) * (self.bbox[3] - self.bbox[1]))


def _distance2bbox(points: np.ndarray, d: np.ndarray) -> np.ndarray:
    return np.stack(
        [points[:, 0] - d[:, 0], points[:, 1] - d[:, 1],
         points[:, 0] + d[:, 2], points[:, 1] + d[:, 3]], axis=-1)


def _distance2kps(points: np.ndarray, d: np.ndarray) -> np.ndarray:
    out = []
    for i in range(0, d.shape[1], 2):
        out.append(points[:, 0] + d[:, i])      # x = anchor_x + dx   (dx already * stride)
        out.append(points[:, 1] + d[:, i + 1])  # y = anchor_y + dy
    return np.stack(out, axis=-1)


def _nms(dets: np.ndarray, thresh: float) -> list[int]:
    x1, y1, x2, y2, scores = dets[:, 0], dets[:, 1], dets[:, 2], dets[:, 3], dets[:, 4]
    areas = (x2 - x1 + 1) * (y2 - y1 + 1)
    order = scores.argsort()[::-1]
    keep = []
    while order.size > 0:
        i = order[0]
        keep.append(int(i))
        xx1 = np.maximum(x1[i], x1[order[1:]])
        yy1 = np.maximum(y1[i], y1[order[1:]])
        xx2 = np.minimum(x2[i], x2[order[1:]])
        yy2 = np.minimum(y2[i], y2[order[1:]])
        inter = np.maximum(0.0, xx2 - xx1 + 1) * np.maximum(0.0, yy2 - yy1 + 1)
        iou = inter / (areas[i] + areas[order[1:]] - inter)
        order = order[np.where(iou <= thresh)[0] + 1]
    return keep


class SCRFDDetector:
    STRIDES = (8, 16, 32)
    NUM_ANCHORS = 2

    def __init__(self, path, input_size=(640, 640), score_thresh=0.5, nms_thresh=0.4):
        self.session = ort.InferenceSession(str(path), providers=["CPUExecutionProvider"])
        self.input_name = self.session.get_inputs()[0].name
        self.output_names = [o.name for o in self.session.get_outputs()]
        if len(self.output_names) != 9:
            raise RuntimeError(
                f"Expected 9 outputs (3 scores + 3 bbox + 3 kps) from SCRFD-KPS, got {len(self.output_names)}. "
                "Are you using the *_kps model?")
        self.input_size = input_size
        self.score_thresh = score_thresh
        self.nms_thresh = nms_thresh
        self._anchor_cache: dict[tuple, np.ndarray] = {}

    def _anchors(self, h: int, w: int, stride: int) -> np.ndarray:
        key = (h, w, stride)
        if key not in self._anchor_cache:
            a = np.stack(np.mgrid[:h, :w][::-1], axis=-1).astype(np.float32)
            a = (a * stride).reshape(-1, 2)
            a = np.stack([a] * self.NUM_ANCHORS, axis=1).reshape(-1, 2)
            self._anchor_cache[key] = a
        return self._anchor_cache[key]

    def detect(self, img: np.ndarray) -> list[Detection]:
        h, w = img.shape[:2]
        iw, ih = self.input_size
        # letterbox (keep aspect ratio, pad bottom/right)
        if (h / w) > (ih / iw):
            new_h, new_w = ih, int(ih / (h / w))
        else:
            new_w, new_h = iw, int(iw * (h / w))
        scale = new_h / h
        canvas = np.zeros((ih, iw, 3), dtype=np.uint8)
        canvas[:new_h, :new_w] = cv2.resize(img, (new_w, new_h))
        blob = cv2.dnn.blobFromImage(canvas, 1.0 / 128, (iw, ih), (127.5, 127.5, 127.5), swapRB=True)

        outs = self.session.run(self.output_names, {self.input_name: blob})
        outs = [o.reshape(-1, o.shape[-1]) for o in outs]

        all_scores, all_boxes, all_kps = [], [], []
        for idx, stride in enumerate(self.STRIDES):
            scores = outs[idx][:, 0]
            bbox_pred = outs[idx + 3] * stride
            kps_pred = outs[idx + 6] * stride
            anchors = self._anchors(ih // stride, iw // stride, stride)
            keep = np.where(scores >= self.score_thresh)[0]
            if keep.size == 0:
                continue
            all_scores.append(scores[keep])
            all_boxes.append(_distance2bbox(anchors, bbox_pred)[keep])
            all_kps.append(_distance2kps(anchors, kps_pred)[keep])

        if not all_scores:
            return []
        scores = np.concatenate(all_scores)
        boxes = np.concatenate(all_boxes) / scale
        kps = np.concatenate(all_kps).reshape(-1, 5, 2) / scale

        dets = np.hstack([boxes, scores[:, None]]).astype(np.float32)
        keep = _nms(dets, self.nms_thresh)
        result = []
        for i in keep:
            b = boxes[i].copy()
            b[[0, 2]] = np.clip(b[[0, 2]], 0, w - 1)
            b[[1, 3]] = np.clip(b[[1, 3]], 0, h - 1)
            result.append(Detection(bbox=b, score=float(scores[i]), kps=kps[i]))
        result.sort(key=lambda d: d.score, reverse=True)
        return result
