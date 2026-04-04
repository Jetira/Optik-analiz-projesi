"""QR kod tespit ve decode servisi.

pyzbar ile goruntudeki QR kodlari bulur, JSON metadata'yi parse eder,
ve merkez + kose koordinatlarini dondurur.
"""

from __future__ import annotations

import json
import logging
from dataclasses import dataclass, field

import numpy as np
from pyzbar.pyzbar import decode, ZBarSymbol

from config import QR_MIN_DETECTED

logger = logging.getLogger(__name__)


@dataclass
class QRResult:
    """Tek bir QR kodun tespit sonucu."""

    raw_data: str
    metadata: dict
    center: tuple[int, int]
    corners: list[tuple[int, int]] = field(default_factory=list)


def detect_qr_codes(image: np.ndarray) -> list[QRResult]:
    """Goruntudeki QR kodlari tespit et ve metadata'yi parse et.

    Args:
        image: BGR veya grayscale numpy dizisi.

    Returns:
        Bulunan QR kodlarin listesi.

    Raises:
        ValueError: QR_MIN_DETECTED'den az QR bulunursa.
    """
    decoded = decode(image, symbols=[ZBarSymbol.QRCODE])
    logger.info("pyzbar %d QR kod buldu", len(decoded))

    results: list[QRResult] = []
    for d in decoded:
        raw = d.data.decode("utf-8", errors="replace")

        # JSON parse
        try:
            metadata = json.loads(raw)
        except json.JSONDecodeError:
            logger.warning("QR verisi JSON degil, atlaniyor: %s", raw[:80])
            continue

        # Merkez ve kose koordinatlari
        polygon = d.polygon  # list of Point(x, y)
        if polygon:
            corners = [(p.x, p.y) for p in polygon]
            cx = sum(p.x for p in polygon) // len(polygon)
            cy = sum(p.y for p in polygon) // len(polygon)
        else:
            r = d.rect
            cx = r.left + r.width // 2
            cy = r.top + r.height // 2
            corners = [
                (r.left, r.top),
                (r.left + r.width, r.top),
                (r.left + r.width, r.top + r.height),
                (r.left, r.top + r.height),
            ]

        results.append(QRResult(
            raw_data=raw,
            metadata=metadata,
            center=(cx, cy),
            corners=corners,
        ))

    if len(results) < QR_MIN_DETECTED:
        raise ValueError(
            f"En az {QR_MIN_DETECTED} QR kod gerekli, {len(results)} bulundu"
        )

    return results
