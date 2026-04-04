"""Cevap anahtari CRUD endpointleri."""

from __future__ import annotations

import json
import logging
from pathlib import Path

from fastapi import APIRouter, HTTPException, Query

from models.schemas import AnswerKey

logger = logging.getLogger(__name__)
router = APIRouter()

DATA_DIR = Path(__file__).resolve().parent.parent / "data"


def _key_path(sinav_id: str, grup: str) -> Path:
    return DATA_DIR / f"{sinav_id}_{grup}.json"


@router.post("/api/answer-key")
async def save_answer_key(key: AnswerKey):
    """Cevap anahtarini JSON dosya olarak kaydet."""
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    path = _key_path(key.sinav_id, key.grup)
    path.write_text(key.model_dump_json(indent=2), encoding="utf-8")
    logger.info("Cevap anahtari kaydedildi: %s", path.name)
    return {"status": "ok", "dosya": path.name}


@router.get("/api/answer-key/{sinav_id}", response_model=AnswerKey)
async def get_answer_key(sinav_id: str, grup: str = Query("A")):
    """Cevap anahtarini getir."""
    path = _key_path(sinav_id, grup)
    if not path.exists():
        raise HTTPException(
            status_code=404,
            detail=f"Cevap anahtari bulunamadi: sinav={sinav_id} grup={grup}",
        )
    data = json.loads(path.read_text(encoding="utf-8"))
    return AnswerKey(**data)


def load_answer_key(sinav_id: str, grup: str) -> AnswerKey | None:
    """Cevap anahtarini dosyadan yukle (servis katmanindan kullanim icin)."""
    path = _key_path(sinav_id, grup)
    if not path.exists():
        return None
    data = json.loads(path.read_text(encoding="utf-8"))
    return AnswerKey(**data)
