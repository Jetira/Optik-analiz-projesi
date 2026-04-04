"""Optical Reader Backend - FastAPI entry point."""

import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Optical Reader API",
    description="Sinav kagidi okuma ve otomatik notlama API",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
from routers.template import router as template_router  # noqa: E402
from routers.scan import router as scan_router  # noqa: E402
from routers.answer_key import router as answer_key_router  # noqa: E402
from routers.grade import router as grade_router  # noqa: E402
from routers.stats import router as stats_router  # noqa: E402
from routers.export import router as export_router  # noqa: E402

app.include_router(template_router)
app.include_router(scan_router)
app.include_router(answer_key_router)
app.include_router(grade_router)
app.include_router(stats_router)
app.include_router(export_router)


@app.get("/health")
async def health_check():
    """Backend saglık kontrolu."""
    return {"status": "ok", "message": "Optical Reader Backend"}
