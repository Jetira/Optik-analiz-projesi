"""GET /api/export/{sinav_id} — Excel export endpointi."""

from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException
from fastapi.responses import Response

from routers.grade import load_results
from services.excel_writer import create_excel
from services.stats_calculator import calculate_stats

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/api/export/{sinav_id}")
async def export_excel(sinav_id: str):
    """Sinav sonuclarini Excel dosyasi olarak dondur."""
    try:
        results = load_results(sinav_id)
        if not results:
            raise HTTPException(
                status_code=404,
                detail=f"Sonuc bulunamadi: sinav={sinav_id}. Henuz puanlama yapilmamis.",
            )

        stats = calculate_stats(sinav_id, results)
        xlsx_bytes = create_excel(
            sinav_id=sinav_id,
            sinav_adi=sinav_id,
            results=results,
            stats=stats,
        )

        filename = f"{sinav_id}_sonuclar.xlsx"
        return Response(
            content=xlsx_bytes,
            media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            headers={"Content-Disposition": f'attachment; filename="{filename}"'},
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Excel export hatasi")
        raise HTTPException(
            status_code=500,
            detail=f"Excel olusturulurken hata olustu: {exc}",
        )
