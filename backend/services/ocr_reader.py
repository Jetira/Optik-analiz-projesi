"""Ogrenci bilgi alani OCR servisi — Gemini Flash Vision API.

Perspektif-duzeltilmis goruntuden Ad Soyad ve Ogrenci No alanlarini
crop edip Gemini Flash ile okur. Bos alan kontrolu ile halusinasyon onlenir.
"""

from __future__ import annotations

import base64
import logging
import os
import re

import cv2
import numpy as np

from config import (
    TEMPLATE_WIDTH,
    STUDENT_INFO_Y,
    STUDENT_INFO_HEIGHT,
    STUDENT_INFO_MARGIN_X,
    STUDENT_INFO_GAP,
)

logger = logging.getLogger(__name__)

# Gemini API ayarlari
_GEMINI_AVAILABLE = False
_model = None

try:
    import google.generativeai as genai

    _api_key = os.environ.get("GEMINI_API_KEY", "")
    if _api_key:
        genai.configure(api_key=_api_key)
        _model = genai.GenerativeModel(
            "gemini-2.0-flash",
            generation_config=genai.GenerationConfig(
                temperature=0.0,
                max_output_tokens=50,
            ),
        )
        _GEMINI_AVAILABLE = True
        logger.info("Gemini Flash OCR aktif")
    else:
        logger.warning("GEMINI_API_KEY ayarlanmamis — OCR devre disi")
except ImportError:
    logger.warning("google-generativeai kurulu degil — OCR devre disi")


# Kutu ici yazi alani icin kenar bosluklari (px)
_PAD_X = 15
_PAD_TOP = 30
_PAD_BOT = 10

# Bos alan tespiti esikleri
_MIN_BLACK_RATIO = 0.01       # bunun altinda kesinlikle bos
_MIN_CONTOUR_COUNT = 1        # bunun altinda yazi yok
_MIN_CONTOUR_AREA_RATIO = 0.0008  # toplam contour alani / ROI alani


def _crop_box(
    image: np.ndarray,
    box_x: int,
    box_w: int,
) -> np.ndarray:
    """Ogrenci bilgi kutusunun yazi alanini crop et."""
    y1 = STUDENT_INFO_Y + _PAD_TOP
    y2 = STUDENT_INFO_Y + STUDENT_INFO_HEIGHT - _PAD_BOT
    x1 = box_x + _PAD_X
    x2 = box_x + box_w - _PAD_X
    return image[y1:y2, x1:x2]


def _has_handwriting(binary: np.ndarray) -> bool:
    """Binary goruntude el yazisi var mi kontrol et.

    Siyah piksel orani, contour sayisi ve contour alan oranini kontrol eder.
    """
    total_pixels = binary.shape[0] * binary.shape[1]
    if total_pixels == 0:
        return False

    # 1. Siyah piksel orani
    black_pixels = total_pixels - cv2.countNonZero(binary)
    black_ratio = black_pixels / total_pixels
    logger.info("OCR check: black_ratio=%.4f (%d/%d)", black_ratio, black_pixels, total_pixels)

    if black_ratio < _MIN_BLACK_RATIO:
        logger.info("OCR: Alan bos (black_ratio < %.3f)", _MIN_BLACK_RATIO)
        return False

    # 2. Contour analizi — gercek yazi benzeri sekiller var mi
    inverted = cv2.bitwise_not(binary)
    contours, _ = cv2.findContours(inverted, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Cok kucuk contour'lari filtrele (gurultu)
    min_area = 10
    significant_contours = [c for c in contours if cv2.contourArea(c) > min_area]

    logger.info("OCR check: contour_count=%d (significant=%d)", len(contours), len(significant_contours))

    if len(significant_contours) < _MIN_CONTOUR_COUNT:
        logger.info("OCR: Yeterli contour yok (%d < %d)", len(significant_contours), _MIN_CONTOUR_COUNT)
        return False

    # 3. Contour alan orani
    total_contour_area = sum(cv2.contourArea(c) for c in significant_contours)
    contour_area_ratio = total_contour_area / total_pixels
    logger.info("OCR check: contour_area_ratio=%.4f", contour_area_ratio)

    if contour_area_ratio < _MIN_CONTOUR_AREA_RATIO:
        logger.info("OCR: Contour alani cok kucuk (%.4f < %.4f)", contour_area_ratio, _MIN_CONTOUR_AREA_RATIO)
        return False

    return True


def _ocr_single(roi: np.ndarray, digits_only: bool = False) -> str | None:
    """Tek bir ROI'ye Gemini Flash Vision OCR uygula."""
    if not _GEMINI_AVAILABLE or _model is None:
        return None

    if roi.size == 0:
        return None

    # Grayscale'e cevir
    if len(roi.shape) == 3:
        gray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
    else:
        gray = roi

    # Kontrast artir
    _, binary = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    # BOS ALAN KONTROLU — yazi yoksa Gemini'ye gonderme
    if not _has_handwriting(binary):
        logger.info("OCR: El yazisi tespit edilemedi — Gemini'ye gonderilmedi")
        return None

    # Goruntuyu buyut ve keskinlestir (Gemini daha iyi okusun)
    h, w = gray.shape[:2]
    if w < 600:
        scale = 600 / w
        gray_upscaled = cv2.resize(gray, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)
    else:
        gray_upscaled = gray

    # CLAHE ile kontrast artir (adaptive histogram equalization)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    gray_enhanced = clahe.apply(gray_upscaled)

    # Keskinlestir
    sharp_kernel = np.array([[0, -1, 0], [-1, 5, -1], [0, -1, 0]])
    gray_sharp = cv2.filter2D(gray_enhanced, -1, sharp_kernel)

    success, buf = cv2.imencode(".png", gray_sharp)
    if not success:
        return None

    image_data = base64.b64encode(buf.tobytes()).decode("utf-8")

    # Gemini'ye gonder
    if digits_only:
        prompt = (
            "This image shows a handwritten student ID number inside a box. "
            "Read each digit very carefully one by one from left to right. "
            "Pay close attention to distinguish between similar digits: 3 vs 5, 1 vs 7, 6 vs 0, 8 vs 0. "
            "Output ONLY the digits, nothing else. "
            "If the box is empty or you cannot read any digits, output exactly: EMPTY"
        )
    else:
        prompt = (
            "This image shows a handwritten Turkish name (first and last name) inside a box. "
            "Read ONLY the name. Output ONLY the name, nothing else. "
            "If the box is empty or you cannot read any text, output exactly: EMPTY"
        )

    try:
        response = _model.generate_content(
            [
                {"mime_type": "image/png", "data": image_data},
                prompt,
            ],
        )
        text = response.text.strip()
    except Exception as exc:
        logger.warning("Gemini OCR hatasi: %s", exc)
        return None

    logger.info("Gemini raw response: '%s' (digits_only=%s)", text, digits_only)

    # EMPTY kontrolu
    if not text or text.upper() in ("EMPTY", "BOS", "NONE", "N/A", "NULL", ""):
        return None

    # Temizlik
    if digits_only:
        text = re.sub(r"[^0-9]", "", text)
        if len(text) < 3:
            logger.info("OCR numara cok kisa: '%s' — atiliyor", text)
            return None
    else:
        text = re.sub(r"[^\w\s]", "", text, flags=re.UNICODE)
        text = " ".join(text.split())
        if len(text) < 2:
            logger.info("OCR isim cok kisa: '%s' — atiliyor", text)
            return None
        words = text.split()
        if len(words) == 1 and len(words[0]) < 3:
            logger.info("OCR isim tek kisa kelime: '%s' — atiliyor", text)
            return None

    return text if text else None


def read_student_info(corrected_image: np.ndarray) -> dict[str, str | None]:
    """Perspektif-duzeltilmis goruntuden ogrenci ad ve no oku."""
    mx = STUDENT_INFO_MARGIN_X
    gap = STUDENT_INFO_GAP
    box_w = (TEMPLATE_WIDTH - 2 * mx - gap) // 2

    # Sol kutu: Ad Soyad
    ad_roi = _crop_box(corrected_image, mx, box_w)
    cv2.imwrite("C:/Users/ahmed/Desktop/debug_ad_roi.png", ad_roi)
    logger.info("OCR debug: ad_roi saved, shape=%s", ad_roi.shape)
    ogrenci_ad = _ocr_single(ad_roi, digits_only=False)

    # Sag kutu: Ogrenci No
    no_x = mx + box_w + gap
    no_roi = _crop_box(corrected_image, no_x, box_w)
    cv2.imwrite("C:/Users/ahmed/Desktop/debug_no_roi.png", no_roi)
    logger.info("OCR debug: no_roi saved, shape=%s", no_roi.shape)
    ogrenci_no = _ocr_single(no_roi, digits_only=True)

    logger.info("OCR sonucu: ad=%s no=%s", ogrenci_ad, ogrenci_no)
    return {"ogrenci_ad": ogrenci_ad, "ogrenci_no": ogrenci_no}
