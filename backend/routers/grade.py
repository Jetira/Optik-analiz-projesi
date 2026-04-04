"""POST /api/grade — puanlama endpointi."""

from __future__ import annotations

import json
import logging
from pathlib import Path

from fastapi import APIRouter, HTTPException

from models.schemas import GradeResult, ScanResult
from routers.answer_key import load_answer_key
from services.grader import grade_exam

logger = logging.getLogger(__name__)
router = APIRouter()

DATA_DIR = Path(__file__).resolve().parent.parent / "data"


def _results_path(sinav_id: str) -> Path:
    """Sinav sonuclari JSON dosya yolu."""
    return DATA_DIR / f"{sinav_id}_results.json"


def load_results(sinav_id: str) -> list[GradeResult]:
    """Kaydedilmis puanlama sonuclarini yukle."""
    path = _results_path(sinav_id)
    if not path.exists():
        return []
    data = json.loads(path.read_text(encoding="utf-8"))
    return [GradeResult(**item) for item in data]


def _save_result(result: GradeResult) -> None:
    """Puanlama sonucunu JSON dosyasina ekle (append)."""
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    path = _results_path(result.sinav_id)

    existing: list[dict] = []
    if path.exists():
        existing = json.loads(path.read_text(encoding="utf-8"))

    existing.append(result.model_dump())
    path.write_text(
        json.dumps(existing, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    logger.info("Sonuc kaydedildi: sinav=%s, dosya=%s", result.sinav_id, path.name)


@router.post("/api/grade", response_model=GradeResult)
async def grade(scan_result: ScanResult):
    """Tarama sonucunu puanla.

    Cevap anahtarini sinav_id + grup'a gore otomatik yukler.
    Sonucu data/{sinav_id}_results.json dosyasina kaydeder.
    """
    try:
        key = load_answer_key(scan_result.sinav_id, scan_result.grup)
        if key is None:
            raise HTTPException(
                status_code=404,
                detail=(
                    f"Cevap anahtari bulunamadi (sinav={scan_result.sinav_id}, "
                    f"grup={scan_result.grup}). "
                    f"Once cevap anahtari kaydedin."
                ),
            )

        result = grade_exam(scan_result, key)
        _save_result(result)
        return result
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Puanlama hatasi")
        raise HTTPException(
            status_code=500,
            detail=f"Puanlama sirasinda beklenmeyen hata: {exc}",
        )
