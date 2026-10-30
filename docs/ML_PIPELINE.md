# ML pipeline
1. Decode JPEG (size limit, max side 1280).
2. SCRFD 500M KPS: bbox + 5 landmarks (keypoints decoded as `offset*stride + anchor`).
3. Quality: face width/height, area ratio, blur (Laplacian variance on a 160x160 face crop). Brightness and pose are NOT checked.
4. Liveness: MiniFASNetV2, crop scale 2.7, 80x80 BGR 0-255. Real class index = `LIVENESS_REAL_INDEX` (1 for this model), threshold `LIVENESS_THRESHOLD`.
5. ArcFace 5-point alignment to 112x112, BGR->RGB, (x-127.5)/127.5, CHW.
6. w600k_mbf -> 512-D, L2-normalised.
7. Matcher: per employee best, top-k mean, median, centroid (metric = `RECOGNITION_SCORE_METRIC`); accept if score >= threshold and margin over 2nd >= `RECOGNITION_MARGIN`.
Enrollment guards: duplicate frame, centroid consistency, and cross-employee similarity (`ENROLL_MAX_CROSS_SIMILARITY`) so one face cannot be enrolled under two codes.
Calibrate with `python -m scripts.diagnose_gallery`. Never lower thresholds to force a match.
