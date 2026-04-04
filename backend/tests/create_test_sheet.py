"""Doldurulmus test sinav kagidi olustur.

Template uzerine bubble'lari ve ogrenci bilgisini programatik olarak doldurur.
"""

import json
import sys
from pathlib import Path

# Backend root'u path'e ekle
backend_dir = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(backend_dir))

from PIL import Image, ImageDraw, ImageFont
from config import BUBBLE_DIAMETER
from services.template_generator import (
    compute_grid_layout,
    generate_template,
    get_bubble_center,
)

# -------------------------------------------------------------------------
# Ayarlar
# -------------------------------------------------------------------------
SINAV_ID = "test-pipeline"
SINAV_ADI = "Pipeline Test Sinavi"
SORU_SAYISI = 10
SIK_SAYISI = 4
GRUP = "A"

# Doldurulacak cevaplar: {soru_no: sik_index} (0=A, 1=B, 2=C, 3=D)
ANSWERS = {
    1: 0,   # A
    2: 1,   # B
    3: 2,   # C
    4: 3,   # D
    5: 0,   # A
    6: 1,   # B
    7: 2,   # C
    8: 3,   # D
    9: 0,   # A
    10: 1,  # B
}

OGRENCI_AD = "Ali Yilmaz"
OGRENCI_NO = "2024001"

OUTPUT_DIR = Path(__file__).resolve().parent / "test_sheets"

# -------------------------------------------------------------------------
# Template olustur
# -------------------------------------------------------------------------
print(f"[1/3] Template olusturuluyor: {SINAV_ID}, {SORU_SAYISI} soru, {SIK_SAYISI} sik, grup {GRUP}")

template_img = generate_template(
    sinav_id=SINAV_ID,
    sinav_adi=SINAV_ADI,
    soru_sayisi=SORU_SAYISI,
    sik_sayisi=SIK_SAYISI,
    grup=GRUP,
)

# -------------------------------------------------------------------------
# Bubble'lari doldur
# -------------------------------------------------------------------------
print("[2/3] Bubble'lar dolduruluyor...")

draw = ImageDraw.Draw(template_img)
layout = compute_grid_layout(SORU_SAYISI, SIK_SAYISI)
fill_r = BUBBLE_DIAMETER // 2 - 2  # Bubble'i dolduracak daire yaricapi

for soru_no, sik_idx in ANSWERS.items():
    cx, cy = get_bubble_center(soru_no, sik_idx, layout)
    draw.ellipse(
        [cx - fill_r, cy - fill_r, cx + fill_r, cy + fill_r],
        fill="black",
    )
    choice_letter = chr(ord("A") + sik_idx)
    print(f"  Soru {soru_no:2d}: {choice_letter} (piksel {cx},{cy})")

# -------------------------------------------------------------------------
# Ogrenci bilgisi yaz
# -------------------------------------------------------------------------
print("[3/3] Ogrenci bilgisi yaziliyor...")

# Ogrenci ad/no alanlarinin yaklasik konumu (config'den)
from config import (
    STUDENT_INFO_Y,
    STUDENT_INFO_HEIGHT,
    STUDENT_INFO_MARGIN_X,
    STUDENT_INFO_GAP,
    TEMPLATE_WIDTH,
)

box_width = (TEMPLATE_WIDTH - 2 * STUDENT_INFO_MARGIN_X - STUDENT_INFO_GAP) // 2
ad_box_x = STUDENT_INFO_MARGIN_X
no_box_x = STUDENT_INFO_MARGIN_X + box_width + STUDENT_INFO_GAP
text_y = STUDENT_INFO_Y + 40  # Kutunun ortasina yaklasik

try:
    font = ImageFont.truetype("arial.ttf", 36)
except OSError:
    font = ImageFont.load_default()

draw.text((ad_box_x + 20, text_y), OGRENCI_AD, fill="black", font=font)
draw.text((no_box_x + 20, text_y), OGRENCI_NO, fill="black", font=font)

# -------------------------------------------------------------------------
# Kaydet
# -------------------------------------------------------------------------
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
output_path = OUTPUT_DIR / "filled_test.png"
template_img.save(str(output_path), "PNG")

print(f"\nBasarili! Doldurulmus sinav kagidi kaydedildi:")
print(f"  {output_path}")
print(f"\nQR Metadata:")
metadata = {
    "sinav_id": SINAV_ID,
    "soru_sayisi": SORU_SAYISI,
    "sik_sayisi": SIK_SAYISI,
    "grup": GRUP,
    "versiyon": 1,
}
print(f"  {json.dumps(metadata, indent=2)}")
