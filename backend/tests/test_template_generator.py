"""Template generator testleri.

Test 1: 20 soru, 4 sik, 2 grup (A, B)
Test 2: 40 soru, 5 sik, 4 grup (A, B, C, D)

Ciktilar: tests/test_templates/ altina kaydedilir.
"""

import sys
from pathlib import Path

# Proje kokunu path'e ekle
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from services.template_generator import (
    generate_all_templates,
    save_template,
    compute_grid_layout,
    get_bubble_center,
)
from config import TEMPLATE_WIDTH, TEMPLATE_HEIGHT, BUBBLE_DIAMETER

OUTPUT_DIR = Path(__file__).parent / "test_templates"


def test_20q_4c_2g():
    """20 soru, 4 sik, 2 grup."""
    templates = generate_all_templates(
        sinav_id="test-20q-4c",
        sinav_adi="Matematik Vize",
        soru_sayisi=20,
        sik_sayisi=4,
        gruplar=["A", "B"],
    )

    assert len(templates) == 2
    for grup, img in templates.items():
        assert img.size == (TEMPLATE_WIDTH, TEMPLATE_HEIGHT)
        save_template(img, OUTPUT_DIR / f"20q_4c_grup_{grup}.png")

    # Grid layout: tek sutun (20 <= 30)
    layout = compute_grid_layout(20, 4)
    assert not layout["two_columns"]
    assert layout["col1_count"] == 20

    # Bubble merkez koordinatlari gecerli olmali
    cx, cy = get_bubble_center(1, 0, layout)
    assert 0 < cx < TEMPLATE_WIDTH
    assert 0 < cy < TEMPLATE_HEIGHT

    cx, cy = get_bubble_center(20, 3, layout)
    assert 0 < cx < TEMPLATE_WIDTH
    assert 0 < cy < TEMPLATE_HEIGHT

    print("PASSED: 20 soru, 4 sik, 2 grup")


def test_40q_5c_4g():
    """40 soru, 5 sik, 4 grup."""
    templates = generate_all_templates(
        sinav_id="test-40q-5c",
        sinav_adi="Fizik Final Sinavi",
        soru_sayisi=40,
        sik_sayisi=5,
        gruplar=["A", "B", "C", "D"],
    )

    assert len(templates) == 4
    for grup, img in templates.items():
        assert img.size == (TEMPLATE_WIDTH, TEMPLATE_HEIGHT)
        save_template(img, OUTPUT_DIR / f"40q_5c_grup_{grup}.png")

    # Grid layout: iki sutun (40 > 30)
    layout = compute_grid_layout(40, 5)
    assert layout["two_columns"]
    assert layout["col1_count"] == 20
    assert layout["col2_count"] == 20

    # Ilk soru, ilk sik
    cx, cy = get_bubble_center(1, 0, layout)
    r = BUBBLE_DIAMETER // 2
    assert cx - r >= 0
    assert cy - r >= 0

    # Son soru, son sik
    cx, cy = get_bubble_center(40, 4, layout)
    assert cx + r <= TEMPLATE_WIDTH
    assert cy + r <= TEMPLATE_HEIGHT

    print("PASSED: 40 soru, 5 sik, 4 grup")


def test_100q_max():
    """100 soru, 5 sik, 1 grup — sinir testi."""
    templates = generate_all_templates(
        sinav_id="test-100q",
        sinav_adi="Genel Kultur",
        soru_sayisi=100,
        sik_sayisi=5,
        gruplar=["A"],
    )

    assert len(templates) == 1
    img = templates["A"]
    assert img.size == (TEMPLATE_WIDTH, TEMPLATE_HEIGHT)
    save_template(img, OUTPUT_DIR / "100q_5c_grup_A.png")

    layout = compute_grid_layout(100, 5)
    assert layout["two_columns"]
    assert layout["col1_count"] == 50
    assert layout["col2_count"] == 50

    # Son soru alt sinirlarda kalmali
    cx, cy = get_bubble_center(100, 4, layout)
    r = BUBBLE_DIAMETER // 2
    assert cy + r < TEMPLATE_HEIGHT, f"Son satir sayfa disina tasiyor: y={cy + r}"

    print("PASSED: 100 soru, 5 sik, 1 grup")


if __name__ == "__main__":
    test_20q_4c_2g()
    test_40q_5c_4g()
    test_100q_max()
    print(f"\nTum testler gecti! Ciktilar: {OUTPUT_DIR.resolve()}")
