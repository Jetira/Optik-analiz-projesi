"""Perspektif duzeltme servisi.

QR kod merkezlerini referans noktasi olarak kullanarak goruntuyu
template koordinat sistemine donusturur (2480x3508 px).
"""

from __future__ import annotations

import logging

import cv2
import numpy as np

from config import (
    TEMPLATE_WIDTH,
    TEMPLATE_HEIGHT,
    QR_MARGIN,
    QR_SIZE,
)
from services.qr_detector import QRResult

logger = logging.getLogger(__name__)

# QR merkezlerinin template koordinat sistemindeki hedef konumlari
_QR_CENTER_OFFSET = QR_MARGIN + QR_SIZE // 2  # 60 + 90 = 150

DST_POINTS = np.array(
    [
        [_QR_CENTER_OFFSET, _QR_CENTER_OFFSET],                                    # TL
        [TEMPLATE_WIDTH - _QR_CENTER_OFFSET, _QR_CENTER_OFFSET],                    # TR
        [_QR_CENTER_OFFSET, TEMPLATE_HEIGHT - _QR_CENTER_OFFSET],                   # BL
        [TEMPLATE_WIDTH - _QR_CENTER_OFFSET, TEMPLATE_HEIGHT - _QR_CENTER_OFFSET],  # BR
    ],
    dtype=np.float32,
)


def _sort_corners(
    centers: list[tuple[int, int]],
) -> tuple[dict[str, tuple[int, int]], tuple[int, int] | None]:
    """QR merkezlerini TL/TR/BL/BR olarak siniflandir.

    4 nokta varsa: sum/diff yontemi.
    3 nokta varsa: en uzun mesafe cifti (capraz), 4.'yu tahmin et.

    Returns:
        ({"tl": ..., "tr": ..., "bl": ..., "br": ...}, estimated_point | None)
    """
    pts = list(centers)

    if len(pts) >= 4:
        pts = pts[:4]
        sums = [p[0] + p[1] for p in pts]
        diffs = [p[0] - p[1] for p in pts]

        tl = pts[sums.index(min(sums))]
        br = pts[sums.index(max(sums))]
        tr = pts[diffs.index(max(diffs))]
        bl = pts[diffs.index(min(diffs))]

        return {"tl": tl, "tr": tr, "bl": bl, "br": br}, None

    # --- 3 nokta: eksik koseyi tahmin et ---
    # En uzun mesafe cifti dikdortgenin caprazindadir
    max_dist_sq = 0
    diag = (0, 1)
    for i in range(3):
        for j in range(i + 1, 3):
            d = (pts[i][0] - pts[j][0]) ** 2 + (pts[i][1] - pts[j][1]) ** 2
            if d > max_dist_sq:
                max_dist_sq = d
                diag = (i, j)

    third = [k for k in range(3) if k not in diag][0]

    # Paralelkenar kurali: P_missing = P_diag0 + P_diag1 - P_third
    p0, p1, p3 = pts[diag[0]], pts[diag[1]], pts[third]
    estimated = (p0[0] + p1[0] - p3[0], p0[1] + p1[1] - p3[1])

    all_pts = pts + [estimated]
    sorted_corners, _ = _sort_corners(all_pts)
    return sorted_corners, estimated


def correct_perspective(
    image: np.ndarray,
    qr_results: list[QRResult],
) -> np.ndarray:
    """Goruntuyü template boyutlarina perspective-warp et.

    Args:
        image: Orijinal goruntu (BGR).
        qr_results: Tespit edilen QR sonuclari (en az 3).

    Returns:
        TEMPLATE_WIDTH x TEMPLATE_HEIGHT boyutunda duzeltilmis goruntu.

    Raises:
        ValueError: QR siniflandirma veya donusum basarisiz olursa.
    """
    centers = [qr.center for qr in qr_results]
    sorted_corners, estimated = _sort_corners(centers)

    if estimated is not None:
        logger.warning(
            "4. QR tahmin edildi: %s (3 QR'dan hesaplandi)", estimated
        )

    # Kaynak noktalar (orijinal goruntudeki QR merkezleri)
    src = np.array(
        [
            sorted_corners["tl"],
            sorted_corners["tr"],
            sorted_corners["bl"],
            sorted_corners["br"],
        ],
        dtype=np.float32,
    )

    matrix = cv2.getPerspectiveTransform(src, DST_POINTS)
    corrected = cv2.warpPerspective(
        image,
        matrix,
        (TEMPLATE_WIDTH, TEMPLATE_HEIGHT),
        flags=cv2.INTER_LINEAR,
        borderValue=(255, 255, 255),
    )

    logger.info("Perspektif duzeltme tamamlandi (%dx%d)", TEMPLATE_WIDTH, TEMPLATE_HEIGHT)
    return corrected
