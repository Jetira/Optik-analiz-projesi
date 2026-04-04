"""Bubble okuma servisi.

Template'den bilinen piksel koordinatlarini kullanarak her bubble'in
doluluk oranini hesaplar. Contour detection YAPMAZ — dogrudan
config'deki grid sabitlerini ve template_generator'daki
compute_grid_layout / get_bubble_center fonksiyonlarini kullanir.

Doluluk olcumu: ROI'nin ortalama piksel yogunluguna dayanir.
Adaptive threshold yerine mean-intensity kullanilir cunku
koordinat-bazli dogrudan ROI okumada daha guvenilirdir
(adaptive threshold kucuk block_size ile buyuk dolu alanlari
yanlis hesaplayabilir).
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field

import cv2
import numpy as np

from config import (
    BUBBLE_DIAMETER,
    BUBBLE_CROP_MARGIN,
    BUBBLE_FILL_THRESHOLD,
    GAUSSIAN_BLUR_KERNEL,
    VALID_CHOICES_4,
    VALID_CHOICES_5,
)
from services.template_generator import compute_grid_layout, get_bubble_center

logger = logging.getLogger(__name__)


@dataclass
class BubbleResult:
    """Tek bir sorunun bubble okuma sonucu."""

    soru_no: int
    cevap: str | None
    gecersiz: bool
    fill_ratios: list[float] = field(default_factory=list)


def read_bubbles(
    corrected_image: np.ndarray,
    soru_sayisi: int,
    sik_sayisi: int,
) -> list[BubbleResult]:
    """Perspektif-duzeltilmis goruntuden bubble cevaplarini oku.

    Args:
        corrected_image: TEMPLATE_WIDTH x TEMPLATE_HEIGHT boyutunda BGR goruntu.
        soru_sayisi: Soru adedi (QR metadata'dan).
        sik_sayisi: Sik adedi, 4 veya 5 (QR metadata'dan).

    Returns:
        Her soru icin BubbleResult listesi.
    """
    # Onisleme: grayscale → blur
    gray = cv2.cvtColor(corrected_image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, GAUSSIAN_BLUR_KERNEL, 0)

    img_h, img_w = blurred.shape
    layout = compute_grid_layout(soru_sayisi, sik_sayisi)
    crop_r = BUBBLE_DIAMETER // 2 - BUBBLE_CROP_MARGIN
    choices = VALID_CHOICES_4 if sik_sayisi == 4 else VALID_CHOICES_5

    results: list[BubbleResult] = []

    for q in range(1, soru_sayisi + 1):
        fill_ratios: list[float] = []

        for c in range(sik_sayisi):
            cx, cy = get_bubble_center(q, c, layout)

            # ROI sinirlari (goruntu disina tasmamali)
            y1 = max(cy - crop_r, 0)
            y2 = min(cy + crop_r, img_h)
            x1 = max(cx - crop_r, 0)
            x2 = min(cx + crop_r, img_w)

            roi = blurred[y1:y2, x1:x2]
            if roi.size == 0:
                fill_ratios.append(0.0)
                continue

            # Mean intensity: 0=siyah(dolu), 255=beyaz(bos)
            # fill_ratio: 0.0=tamamen bos, 1.0=tamamen dolu
            mean_val = float(np.mean(roi))
            ratio = 1.0 - (mean_val / 255.0)
            fill_ratios.append(ratio)

        # Karar: hangi sik(lar) isaretli?
        marked = [i for i, fr in enumerate(fill_ratios) if fr > BUBBLE_FILL_THRESHOLD]

        if len(marked) == 0:
            cevap = None
            gecersiz = False
        elif len(marked) == 1:
            cevap = choices[marked[0]]
            gecersiz = False
        else:
            # Birden fazla isaretleme → gecersiz
            cevap = None
            gecersiz = True

        results.append(BubbleResult(
            soru_no=q,
            cevap=cevap,
            gecersiz=gecersiz,
            fill_ratios=fill_ratios,
        ))

    # Ozet log
    answered = sum(1 for r in results if r.cevap is not None)
    blank = sum(1 for r in results if r.cevap is None and not r.gecersiz)
    invalid = sum(1 for r in results if r.gecersiz)
    logger.info(
        "Bubble okuma: %d soru — %d cevapli, %d bos, %d gecersiz",
        soru_sayisi, answered, blank, invalid,
    )

    return results
