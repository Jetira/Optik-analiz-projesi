"""POST /api/scan — tek goruntu tarama pipeline."""

from __future__ import annotations

import logging

import cv2
import numpy as np
from fastapi import APIRouter, File, Form, HTTPException, UploadFile

from config import BUBBLE_FILL_THRESHOLD
from models.schemas import ScanResult, StudentAnswer
from services.qr_detector import detect_qr_codes
from services.perspective import correct_perspective
from services.bubble_reader import read_bubbles
from services.ocr_reader import read_student_info
from services.generic_reader import read_generic_sheet

logger = logging.getLogger(__name__)
router = APIRouter()

# Belirsiz bubble fill_ratio araligi
_AMBIGUOUS_LOW = BUBBLE_FILL_THRESHOLD - 0.15   # 0.35
_AMBIGUOUS_HIGH = BUBBLE_FILL_THRESHOLD + 0.15  # 0.65


@router.post("/api/scan")
async def scan_image(file: UploadFile = File(...)):
    """Tek bir sinav kagidi goruntusunu isleyip sonuc dondurur.

    Pipeline:
        image decode -> QR detect -> perspective correct -> bubble read -> JSON
    """
    try:
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if image is None:
            raise HTTPException(
                status_code=400,
                detail="Goruntu dosyasi okunamadi. Desteklenen formatlar: JPEG, PNG.",
            )

        logger.info(
            "Tarama basladi: dosya=%s boyut=%dx%d",
            file.filename,
            image.shape[1],
            image.shape[0],
        )

        # 1. QR tespit
        try:
            qr_results = detect_qr_codes(image)
        except ValueError:
            raise HTTPException(
                status_code=400,
                detail=(
                    "4 kosede QR kod bulunamadi. "
                    "Kagidi duz bir yuzey uzerine koyup tekrar cekin. "
                    "Isik yansimasi ve golge olmamasina dikkat edin."
                ),
            )

        metadata = qr_results[0].metadata
        sinav_id = metadata.get("sinav_id", "")
        soru_sayisi = metadata.get("soru_sayisi", 0)
        sik_sayisi = metadata.get("sik_sayisi", 4)
        grup = metadata.get("grup", "?")

        logger.info(
            "QR metadata: sinav=%s grup=%s soru=%d sik=%d",
            sinav_id, grup, soru_sayisi, sik_sayisi,
        )

        # 2. Perspektif duzeltme
        try:
            corrected = correct_perspective(image, qr_results)
        except Exception as exc:
            logger.error("Perspektif duzeltme hatasi: %s", exc)
            raise HTTPException(
                status_code=400,
                detail=(
                    "Perspektif duzeltme basarisiz. "
                    "Kagit tamamen gorunur olmali ve burusuk olmamali."
                ),
            )

        # 3. OCR — ogrenci ad/no
        student_info = read_student_info(corrected)

        # 4. Bubble okuma
        bubble_results = read_bubbles(corrected, soru_sayisi, sik_sayisi)

        # 5. Uyari tespiti — belirsiz bubble'lar
        warnings: list[str] = []
        for b in bubble_results:
            for i, fr in enumerate(b.fill_ratios):
                if _AMBIGUOUS_LOW < fr < _AMBIGUOUS_HIGH:
                    choice_label = chr(ord("A") + i)
                    warnings.append(
                        f"Soru {b.soru_no}, sik {choice_label}: "
                        f"doluluk belirsiz (%{fr * 100:.0f})"
                    )

        # 6. Sonuc
        cevaplar = [
            StudentAnswer(
                soru_no=b.soru_no,
                cevap=b.cevap,
                gecersiz=b.gecersiz,
            )
            for b in bubble_results
        ]

        response = ScanResult(
            ogrenci_ad=student_info["ogrenci_ad"],
            ogrenci_no=student_info["ogrenci_no"],
            sinav_id=sinav_id,
            grup=grup,
            soru_sayisi=soru_sayisi,
            sik_sayisi=sik_sayisi,
            cevaplar=cevaplar,
        ).model_dump()

        if warnings:
            response["warnings"] = warnings
            logger.warning("Belirsiz bubble'lar: %s", warnings)

        return response

    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Beklenmeyen tarama hatasi")
        raise HTTPException(
            status_code=500,
            detail=f"Tarama sirasinda beklenmeyen hata olustu: {exc}",
        )


@router.post("/api/scan/generic")
async def scan_generic(
    file: UploadFile = File(...),
    soru_sayisi: int = Form(20),
    sik_sayisi: int = Form(4),
) -> dict:
    """Rastgele optik kagidi Gemini Vision ile oku."""
    contents = await file.read()
    try:
        result = read_generic_sheet(contents, soru_sayisi, sik_sayisi)
        return result
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc))
