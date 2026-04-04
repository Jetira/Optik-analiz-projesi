"""POST /api/template — sinav kagidi template uretimi."""

from __future__ import annotations

import io
import logging
import zipfile

from fastapi import APIRouter
from fastapi.responses import Response, StreamingResponse

from models.schemas import ExamConfig
from services.template_generator import (
    generate_all_templates,
    image_to_bytes,
)

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/api/template")
async def create_template(config: ExamConfig):
    """Sinav kagidi template PNG(ler) uretir.

    - Tek grup  → image/png yaniti
    - Birden fazla grup → application/zip (her grup icin ayri PNG)
    """
    templates = generate_all_templates(
        sinav_id=config.sinav_id,
        sinav_adi=config.sinav_adi,
        soru_sayisi=config.soru_sayisi,
        sik_sayisi=config.sik_sayisi,
        gruplar=config.gruplar,
    )

    if len(templates) == 1:
        grup, img = next(iter(templates.items()))
        png_bytes = image_to_bytes(img)
        filename = f"{config.sinav_id}_grup_{grup}.png"
        return Response(
            content=png_bytes,
            media_type="image/png",
            headers={"Content-Disposition": f'attachment; filename="{filename}"'},
        )

    # Birden fazla grup → ZIP
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        for grup, img in templates.items():
            png_bytes = image_to_bytes(img)
            zf.writestr(f"{config.sinav_id}_grup_{grup}.png", png_bytes)
    buf.seek(0)

    filename = f"{config.sinav_id}_templates.zip"
    return StreamingResponse(
        buf,
        media_type="application/zip",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
