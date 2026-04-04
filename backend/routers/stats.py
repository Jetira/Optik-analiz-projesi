"""GET /api/stats/{sinav_id} — istatistik endpointi."""

from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException

from models.schemas import ExamStats
from routers.grade import load_results
from services.stats_calculator import calculate_stats

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/api/stats/{sinav_id}", response_model=ExamStats)
async def get_stats(sinav_id: str):
    """Sinav istatistiklerini hesapla ve dondur."""
    try:
        results = load_results(sinav_id)
        if not results:
            raise HTTPException(
                status_code=404,
                detail=f"Sonuc bulunamadi: sinav={sinav_id}. Henuz puanlama yapilmamis.",
            )

        stats = calculate_stats(sinav_id, results)
        return stats
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Istatistik hesaplama hatasi")
        raise HTTPException(
            status_code=500,
            detail=f"Istatistik hesaplanirken hata olustu: {exc}",
        )
