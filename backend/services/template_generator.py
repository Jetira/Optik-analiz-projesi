"""Sinav kagidi template olusturucu.

Her grup icin ayri A4 (2480x3508 px, 300 DPI) PNG uretir.
Icerik: 4-kose QR, baslik, ogrenci bilgi alani, bubble grid.
"""

from __future__ import annotations

import io
import json
import logging
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
import qrcode

from config import (
    TEMPLATE_WIDTH,
    TEMPLATE_HEIGHT,
    TEMPLATE_DPI,
    QR_SIZE,
    QR_MARGIN,
    TITLE_Y,
    GROUP_LABEL_Y,
    STUDENT_INFO_Y,
    STUDENT_INFO_HEIGHT,
    STUDENT_INFO_MARGIN_X,
    STUDENT_INFO_GAP,
    BUBBLE_GRID_START_Y,
    BUBBLE_DIAMETER,
    BUBBLE_SPACING_X,
    ROW_HEIGHT,
    QUESTION_LABEL_WIDTH,
    TWO_COLUMN_THRESHOLD,
    COLUMN_GAP,
    FONT_SIZE_TITLE,
    FONT_SIZE_GROUP,
    FONT_SIZE_LABEL,
    FONT_SIZE_QUESTION,
    FONT_SIZE_CHOICE,
    VALID_CHOICES_4,
    VALID_CHOICES_5,
)

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Font helper
# ---------------------------------------------------------------------------

_FONT_CANDIDATES = [
    "arial.ttf",
    "Arial.ttf",
    "C:/Windows/Fonts/arial.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "DejaVuSans.ttf",
]


def _get_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for name in _FONT_CANDIDATES:
        try:
            return ImageFont.truetype(name, size)
        except (OSError, IOError):
            continue
    # Pillow 10+ supports size param in load_default
    try:
        return ImageFont.load_default(size=size)
    except TypeError:
        return ImageFont.load_default()


# ---------------------------------------------------------------------------
# QR code helper
# ---------------------------------------------------------------------------


def _make_qr_image(data: str, size: int) -> Image.Image:
    """JSON string -> siyah-beyaz QR kod PIL Image (size x size px)."""
    qr = qrcode.QRCode(
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=10,
        border=2,
    )
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white").convert("RGB")
    return img.resize((size, size), Image.NEAREST)


# ---------------------------------------------------------------------------
# Grid layout calculation
# ---------------------------------------------------------------------------


def compute_grid_layout(
    soru_sayisi: int,
    sik_sayisi: int,
) -> dict:
    """Bubble grid icin kolon/satir duzeni hesapla.

    Donen dict anahtarlari:
        two_columns, col1_count, col2_count, col1_x, col2_x, row_width
    """
    two_columns = soru_sayisi > TWO_COLUMN_THRESHOLD

    if two_columns:
        col1_count = math.ceil(soru_sayisi / 2)
        col2_count = soru_sayisi - col1_count
    else:
        col1_count = soru_sayisi
        col2_count = 0

    # Bir soru satirinin genisligi:
    #   etiket + (sik_sayisi - 1) * spacing + diameter
    row_width = QUESTION_LABEL_WIDTH + (sik_sayisi - 1) * BUBBLE_SPACING_X + BUBBLE_DIAMETER

    if two_columns:
        total_width = 2 * row_width + COLUMN_GAP
    else:
        total_width = row_width

    start_x = (TEMPLATE_WIDTH - total_width) // 2

    col1_x = start_x
    col2_x = start_x + row_width + COLUMN_GAP if two_columns else 0

    return {
        "two_columns": two_columns,
        "col1_count": col1_count,
        "col2_count": col2_count,
        "col1_x": col1_x,
        "col2_x": col2_x,
        "row_width": row_width,
    }


def get_bubble_center(
    question_no: int,
    choice_index: int,
    layout: dict,
) -> tuple[int, int]:
    """1-tabanli soru numarasi + 0-tabanli sik index -> (x, y) merkez koordinati."""
    if layout["two_columns"] and question_no > layout["col1_count"]:
        col_x = layout["col2_x"]
        row_idx = question_no - layout["col1_count"] - 1
    else:
        col_x = layout["col1_x"]
        row_idx = question_no - 1

    r = BUBBLE_DIAMETER // 2
    x = col_x + QUESTION_LABEL_WIDTH + choice_index * BUBBLE_SPACING_X + r
    y = BUBBLE_GRID_START_Y + row_idx * ROW_HEIGHT

    return (x, y)


# ---------------------------------------------------------------------------
# Drawing helpers
# ---------------------------------------------------------------------------


def _draw_qr_codes(img: Image.Image, qr_data: str) -> None:
    qr_img = _make_qr_image(qr_data, QR_SIZE)
    w, h = TEMPLATE_WIDTH, TEMPLATE_HEIGHT
    m, s = QR_MARGIN, QR_SIZE

    img.paste(qr_img, (m, m))                          # sol-ust
    img.paste(qr_img, (w - m - s, m))                   # sag-ust
    img.paste(qr_img, (m, h - m - s))                   # sol-alt
    img.paste(qr_img, (w - m - s, h - m - s))           # sag-alt


def _draw_title(draw: ImageDraw.ImageDraw, sinav_adi: str, grup: str) -> None:
    font_title = _get_font(FONT_SIZE_TITLE)
    font_group = _get_font(FONT_SIZE_GROUP)
    cx = TEMPLATE_WIDTH // 2

    draw.text((cx, TITLE_Y), sinav_adi, fill="black", font=font_title, anchor="mm")
    draw.text((cx, GROUP_LABEL_Y), f"GRUP {grup}", fill="black", font=font_group, anchor="mm")


def _draw_student_info(draw: ImageDraw.ImageDraw) -> None:
    font = _get_font(FONT_SIZE_LABEL)
    mx = STUDENT_INFO_MARGIN_X
    gap = STUDENT_INFO_GAP
    top = STUDENT_INFO_Y
    h = STUDENT_INFO_HEIGHT
    box_w = (TEMPLATE_WIDTH - 2 * mx - gap) // 2

    # Sol kutu — Ad Soyad
    x1 = mx
    draw.rectangle([x1, top, x1 + box_w, top + h], outline="black", width=3)
    draw.text((x1 + 15, top + 10), "Ad Soyad:", fill="black", font=font)
    line_y = top + 55
    draw.line([(x1 + 15, line_y), (x1 + box_w - 15, line_y)], fill="gray", width=1)

    # Sag kutu — Ogrenci No
    x2 = mx + box_w + gap
    draw.rectangle([x2, top, x2 + box_w, top + h], outline="black", width=3)
    draw.text((x2 + 15, top + 10), "Ogrenci No:", fill="black", font=font)
    draw.line([(x2 + 15, line_y), (x2 + box_w - 15, line_y)], fill="gray", width=1)


def _draw_bubble_grid(
    draw: ImageDraw.ImageDraw,
    soru_sayisi: int,
    sik_sayisi: int,
    layout: dict,
) -> None:
    font_q = _get_font(FONT_SIZE_QUESTION)
    font_c = _get_font(FONT_SIZE_CHOICE)
    r = BUBBLE_DIAMETER // 2
    choices = VALID_CHOICES_4 if sik_sayisi == 4 else VALID_CHOICES_5

    def _draw_column(col_x: int, start_q: int, count: int) -> None:
        # Sik baslik satiri (A, B, C, D, ...)
        header_y = BUBBLE_GRID_START_Y - 40
        for ci, ch in enumerate(choices):
            cx = col_x + QUESTION_LABEL_WIDTH + ci * BUBBLE_SPACING_X + r
            draw.text((cx, header_y), ch, fill="black", font=font_c, anchor="mm")

        # Soru satirlari
        for row in range(count):
            q_num = start_q + row
            cy = BUBBLE_GRID_START_Y + row * ROW_HEIGHT

            # Soru numarasi (sag-hizali)
            label_x = col_x + QUESTION_LABEL_WIDTH - 12
            draw.text(
                (label_x, cy),
                f"{q_num}.",
                fill="black",
                font=font_q,
                anchor="rm",
            )

            # Bubble daireleri
            for ci in range(sik_sayisi):
                cx = col_x + QUESTION_LABEL_WIDTH + ci * BUBBLE_SPACING_X + r
                draw.ellipse(
                    [cx - r, cy - r, cx + r, cy + r],
                    outline="black",
                    width=2,
                )

    _draw_column(layout["col1_x"], 1, layout["col1_count"])
    if layout["two_columns"]:
        _draw_column(layout["col2_x"], layout["col1_count"] + 1, layout["col2_count"])


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


def generate_template(
    sinav_id: str,
    sinav_adi: str,
    soru_sayisi: int,
    sik_sayisi: int,
    grup: str,
) -> Image.Image:
    """Tek bir grup icin A4 template PNG olusturur."""
    img = Image.new("RGB", (TEMPLATE_WIDTH, TEMPLATE_HEIGHT), "white")
    draw = ImageDraw.Draw(img)

    # QR metadata
    qr_payload = json.dumps(
        {
            "sinav_id": sinav_id,
            "soru_sayisi": soru_sayisi,
            "sik_sayisi": sik_sayisi,
            "grup": grup,
            "versiyon": 1,
        },
        ensure_ascii=False,
    )

    _draw_qr_codes(img, qr_payload)
    _draw_title(draw, sinav_adi, grup)
    _draw_student_info(draw)

    layout = compute_grid_layout(soru_sayisi, sik_sayisi)
    _draw_bubble_grid(draw, soru_sayisi, sik_sayisi, layout)

    return img


def generate_all_templates(
    sinav_id: str,
    sinav_adi: str,
    soru_sayisi: int,
    sik_sayisi: int,
    gruplar: list[str],
) -> dict[str, Image.Image]:
    """Tum gruplar icin template uretir. {grup: Image} dict doner."""
    results: dict[str, Image.Image] = {}
    for grup in gruplar:
        logger.info("Template uretiliyor: sinav=%s grup=%s", sinav_id, grup)
        results[grup] = generate_template(
            sinav_id, sinav_adi, soru_sayisi, sik_sayisi, grup
        )
    return results


def image_to_bytes(img: Image.Image) -> bytes:
    """PIL Image -> PNG bytes."""
    buf = io.BytesIO()
    img.save(buf, format="PNG", dpi=(TEMPLATE_DPI, TEMPLATE_DPI))
    return buf.getvalue()


def save_template(img: Image.Image, path: str | Path) -> Path:
    """Template'i diske PNG olarak kaydet."""
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    img.save(str(p), format="PNG", dpi=(TEMPLATE_DPI, TEMPLATE_DPI))
    logger.info("Template kaydedildi: %s", p)
    return p
