import numpy as np

from app.ml.alignment import ARCFACE_TEMPLATE, align_face
from app.ml.detector import _distance2kps, _nms
from app.ml.matcher import GalleryMatcher
from app.utils.similarity import l2_normalize


def rand_unit(rng, n=512):
    return l2_normalize(rng.normal(size=n).astype(np.float32))


def person(rng, k=6, noise=0.03):
    base = rand_unit(rng)
    return base, [l2_normalize(base + noise * rng.normal(size=512).astype(np.float32)) for _ in range(k)]


def test_kps_decode_adds_anchor_after_stride():
    anchors = np.array([[16.0, 32.0]], dtype=np.float32)
    d = np.ones((1, 10), dtype=np.float32) * 8  # already * stride
    k = _distance2kps(anchors, d).reshape(5, 2)
    assert np.allclose(k[:, 0], 24) and np.allclose(k[:, 1], 40)


def test_nms_removes_overlap():
    d = np.array([[0, 0, 100, 100, 0.9], [5, 5, 100, 100, 0.8], [300, 300, 400, 400, 0.7]], dtype=np.float32)
    assert _nms(d, 0.4) == [0, 2]


def test_alignment_identity():
    img = np.random.randint(0, 255, (112, 112, 3), dtype=np.uint8)
    out = align_face(img, ARCFACE_TEMPLATE.copy())
    assert out.shape == (112, 112, 3)
    assert np.abs(out.astype(int) - img.astype(int)).mean() < 2


def test_matcher_recognizes_and_rejects_unknown():
    rng = np.random.default_rng(1)
    m = GalleryMatcher(0.45, 0.08)
    ba, ea = person(rng); bb, eb = person(rng)
    m.set_gallery([(1, "A", "Alice", ea), (2, "B", "Bob", eb)])
    r = m.match(l2_normalize(ba + 0.03 * rng.normal(size=512).astype(np.float32)))
    assert r.recognized and r.employee_code == "A"
    unknown = rand_unit(rng)
    assert not m.match(unknown).recognized


def test_matcher_margin_rule():
    rng = np.random.default_rng(2)
    base = rand_unit(rng)
    twin = l2_normalize(base + 0.005 * rng.normal(size=512).astype(np.float32))
    m = GalleryMatcher(0.45, 0.08)
    m.set_gallery([(1, "A", "A", [base] * 3), (2, "B", "B", [twin] * 3)])
    r = m.match(base)
    assert not r.recognized and r.reason == "insufficient_margin"


def test_empty_gallery():
    assert m_reason(GalleryMatcher(0.45, 0.08)) == "gallery_empty"


def m_reason(m):
    return m.match(np.ones(512, dtype=np.float32) / 22.6).reason
