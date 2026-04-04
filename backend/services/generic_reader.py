"""Rastgele optik kagit okuma servisi — Gemini Vision API.

Herhangi bir optik formdaki bubble isaretlemelerini Gemini ile okur.
QR kod veya sabit template gerektirmez.
"""

from __future__ import annotations

import base64
import json
import logging
import os

logger = logging.getLogger(__name__)

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
                max_output_tokens=4096,
            ),
        )
        _GEMINI_AVAILABLE = True
except ImportError:
    pass


def read_generic_sheet(image_bytes: bytes, soru_sayisi: int, sik_sayisi: int) -> dict:
    """Rastgele optik kagidi Gemini Vision ile oku.

    Args:
        image_bytes: JPEG/PNG goruntu verisi.
        soru_sayisi: Beklenen soru sayisi.
        sik_sayisi: Beklenen sik sayisi (4 veya 5).

    Returns:
        dict with ogrenci_ad, ogrenci_no, cevaplar list.
    """
    if not _GEMINI_AVAILABLE or _model is None:
        raise RuntimeError("Gemini API kulanilamiyor")

    image_data = base64.b64encode(image_bytes).decode("utf-8")

    sik_harfleri = "A, B, C, D" if sik_sayisi == 4 else "A, B, C, D, E"

    prompt = f"""This is a photo of an optical answer sheet (bubble sheet / OMR sheet) from a multiple choice exam.

The exam has {soru_sayisi} questions with {sik_sayisi} choices each ({sik_harfleri}).

Analyze the image carefully and determine which bubble is filled/marked for each question.

Also look for a student name and student number field - read them if they exist.

Respond ONLY in this exact JSON format, nothing else:
{{
  "ogrenci_ad": "student name or null",
  "ogrenci_no": "student number or null",
  "cevaplar": [
    {{"soru_no": 1, "cevap": "A", "gecersiz": false}},
    {{"soru_no": 2, "cevap": null, "gecersiz": false}},
    {{"soru_no": 3, "cevap": "B", "gecersiz": false}}
  ]
}}

Rules:
- cevap is the letter of the filled bubble (A/B/C/D/E) or null if no bubble is filled
- gecersiz is true if multiple bubbles are filled for the same question
- Include all {soru_sayisi} questions in order
- ogrenci_ad and ogrenci_no are null if not found or unreadable
- Output ONLY valid JSON, no explanation"""

    try:
        response = _model.generate_content(
            [
                {"mime_type": "image/jpeg", "data": image_data},
                prompt,
            ],
        )
        text = response.text.strip()

        # Gemini bazen ```json ... ``` ile sarar
        if text.startswith("```"):
            text = text.split("```")[1]
            if text.startswith("json"):
                text = text[4:]
        text = text.strip()

        result = json.loads(text)
        logger.info("Generic reader: %d soru okundu", len(result.get("cevaplar", [])))
        return result

    except Exception as exc:
        logger.error("Generic reader hatasi: %s", exc)
        raise RuntimeError(f"Optik okuma basarisiz: {exc}")
