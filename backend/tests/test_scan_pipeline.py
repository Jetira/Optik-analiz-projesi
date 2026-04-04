"""Scan pipeline end-to-end testleri.

Template PNG uretir, Pillow ile belirli bubble'lari doldurur,
pipeline'dan gecirip okunan cevaplari dogrular.
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from config import BUBBLE_DIAMETER, VALID_CHOICES_4, VALID_CHOICES_5
from services.template_generator import (
    generate_template,
    compute_grid_layout,
    get_bubble_center,
    save_template,
)
from services.qr_detector import detect_qr_codes
from services.perspective import correct_perspective
from services.bubble_reader import read_bubbles

OUTPUT_DIR = Path(__file__).parent / "test_templates"


def _fill_bubbles(
    img: Image.Image,
    answers: dict[int, int],
    soru_sayisi: int,
    sik_sayisi: int,
) -> Image.Image:
    """Template uzerinde belirli bubble'lari siyahla doldurur.

    Args:
        img: Template PIL Image.
        answers: {soru_no: choice_index} — 1-tabanli soru, 0-tabanli sik.
        soru_sayisi: Toplam soru sayisi.
        sik_sayisi: Sik sayisi (4 veya 5).

    Returns:
        Doldurulmus PIL Image.
    """
    img = img.copy()
    draw = ImageDraw.Draw(img)
    layout = compute_grid_layout(soru_sayisi, sik_sayisi)
    fill_r = BUBBLE_DIAMETER // 2 - 3  # outline'in icine doldur

    for q_no, c_idx in answers.items():
        cx, cy = get_bubble_center(q_no, c_idx, layout)
        draw.ellipse(
            [cx - fill_r, cy - fill_r, cx + fill_r, cy + fill_r],
            fill="black",
        )

    return img


def _fill_multiple_bubbles(
    img: Image.Image,
    multi: dict[int, list[int]],
    soru_sayisi: int,
    sik_sayisi: int,
) -> Image.Image:
    """Bir soruda birden fazla siki doldurur (gecersiz durumu icin)."""
    img = img.copy()
    draw = ImageDraw.Draw(img)
    layout = compute_grid_layout(soru_sayisi, sik_sayisi)
    fill_r = BUBBLE_DIAMETER // 2 - 3

    for q_no, c_indices in multi.items():
        for c_idx in c_indices:
            cx, cy = get_bubble_center(q_no, c_idx, layout)
            draw.ellipse(
                [cx - fill_r, cy - fill_r, cx + fill_r, cy + fill_r],
                fill="black",
            )

    return img


def _run_pipeline(img: Image.Image) -> list:
    """PIL Image -> numpy BGR -> QR detect -> perspective -> bubble read."""
    # PIL (RGB) -> numpy (BGR)
    img_rgb = np.array(img)
    img_bgr = img_rgb[:, :, ::-1].copy()

    qr_results = detect_qr_codes(img_bgr)
    metadata = qr_results[0].metadata

    corrected = correct_perspective(img_bgr, qr_results)
    bubble_results = read_bubbles(
        corrected,
        metadata["soru_sayisi"],
        metadata["sik_sayisi"],
    )

    return bubble_results


# ====================================================================
# Test 1: Normal okuma — 20 soru, 4 sik, belirli cevaplar
# ====================================================================


def test_normal_read():
    """Bilinen cevaplari doldur, oku, dogrula."""
    soru_sayisi = 20
    sik_sayisi = 4
    choices = VALID_CHOICES_4

    # Beklenen cevaplar: 1->A, 2->B, 3->C, 4->D, 5->A, ...
    expected = {}
    for q in range(1, soru_sayisi + 1):
        expected[q] = (q - 1) % sik_sayisi

    img = generate_template("test-normal", "Normal Okuma Testi", soru_sayisi, sik_sayisi, "A")
    img = _fill_bubbles(img, expected, soru_sayisi, sik_sayisi)
    save_template(img, OUTPUT_DIR / "test_normal_filled.png")

    results = _run_pipeline(img)

    assert len(results) == soru_sayisi
    for r in results:
        exp_choice = choices[expected[r.soru_no]]
        assert r.cevap == exp_choice, (
            f"Soru {r.soru_no}: beklenen={exp_choice}, okunan={r.cevap}, "
            f"ratios={[f'{x:.2f}' for x in r.fill_ratios]}"
        )
        assert not r.gecersiz

    print(f"PASSED: Normal okuma — {soru_sayisi} soru, tumu dogru eslesti")


# ====================================================================
# Test 2: Bos birakilan sorular
# ====================================================================


def test_blank_questions():
    """Bazi sorulari bos birak, bos olarak okunduklarini dogrula."""
    soru_sayisi = 20
    sik_sayisi = 4
    choices = VALID_CHOICES_4

    # Sadece tek sorulari doldur (1,3,5,...,19), cift olanlar bos
    filled = {q: (q - 1) % sik_sayisi for q in range(1, soru_sayisi + 1, 2)}

    img = generate_template("test-blank", "Bos Soru Testi", soru_sayisi, sik_sayisi, "B")
    img = _fill_bubbles(img, filled, soru_sayisi, sik_sayisi)
    save_template(img, OUTPUT_DIR / "test_blank_filled.png")

    results = _run_pipeline(img)

    assert len(results) == soru_sayisi
    for r in results:
        if r.soru_no in filled:
            exp_choice = choices[filled[r.soru_no]]
            assert r.cevap == exp_choice, (
                f"Soru {r.soru_no}: beklenen={exp_choice}, okunan={r.cevap}"
            )
        else:
            assert r.cevap is None, (
                f"Soru {r.soru_no}: bos olmali, okunan={r.cevap}, "
                f"ratios={[f'{x:.2f}' for x in r.fill_ratios]}"
            )
        assert not r.gecersiz

    blank_count = sum(1 for r in results if r.cevap is None)
    print(f"PASSED: Bos sorular — {blank_count} bos, {soru_sayisi - blank_count} dolu")


# ====================================================================
# Test 3: Gecersiz (cift isaretleme)
# ====================================================================


def test_invalid_double_mark():
    """Bazi sorularda 2 sik isaretleyerek gecersiz durumu olustur."""
    soru_sayisi = 20
    sik_sayisi = 4

    # Soru 1-10: normal tek isaretleme
    single = {q: 0 for q in range(1, 11)}
    # Soru 11-15: cift isaretleme (gecersiz)
    double = {q: [0, 2] for q in range(11, 16)}
    # Soru 16-20: bos

    img = generate_template("test-invalid", "Gecersiz Testi", soru_sayisi, sik_sayisi, "A")
    img = _fill_bubbles(img, single, soru_sayisi, sik_sayisi)
    img = _fill_multiple_bubbles(img, double, soru_sayisi, sik_sayisi)
    save_template(img, OUTPUT_DIR / "test_invalid_filled.png")

    results = _run_pipeline(img)

    assert len(results) == soru_sayisi

    for r in results:
        if r.soru_no <= 10:
            assert r.cevap == "A", f"Soru {r.soru_no}: beklenen=A, okunan={r.cevap}"
            assert not r.gecersiz
        elif r.soru_no <= 15:
            assert r.gecersiz, (
                f"Soru {r.soru_no}: gecersiz olmali, "
                f"ratios={[f'{x:.2f}' for x in r.fill_ratios]}"
            )
        else:
            assert r.cevap is None and not r.gecersiz, (
                f"Soru {r.soru_no}: bos olmali"
            )

    invalid_count = sum(1 for r in results if r.gecersiz)
    print(f"PASSED: Gecersiz — {invalid_count} gecersiz isaretleme tespit edildi")


# ====================================================================
# Test 4: 2-sutun layout — 40 soru, 5 sik
# ====================================================================


def test_two_column_layout():
    """40 soru / 5 sik / 2-sutun layout'ta dogruluk testi."""
    soru_sayisi = 40
    sik_sayisi = 5
    choices = VALID_CHOICES_5

    # Her soru icin farkli sik: soru 1->A, 2->B, ..., 5->E, 6->A, ...
    expected = {q: (q - 1) % sik_sayisi for q in range(1, soru_sayisi + 1)}

    img = generate_template("test-2col", "Cift Sutun Testi", soru_sayisi, sik_sayisi, "C")
    img = _fill_bubbles(img, expected, soru_sayisi, sik_sayisi)
    save_template(img, OUTPUT_DIR / "test_twocol_filled.png")

    results = _run_pipeline(img)

    assert len(results) == soru_sayisi
    for r in results:
        exp_choice = choices[expected[r.soru_no]]
        assert r.cevap == exp_choice, (
            f"Soru {r.soru_no}: beklenen={exp_choice}, okunan={r.cevap}, "
            f"ratios={[f'{x:.2f}' for x in r.fill_ratios]}"
        )
        assert not r.gecersiz

    print(f"PASSED: 2-sutun layout — {soru_sayisi} soru, tumu dogru eslesti")


if __name__ == "__main__":
    test_normal_read()
    test_blank_questions()
    test_invalid_double_mark()
    test_two_column_layout()
    print(f"\nTum pipeline testleri gecti! Ciktilar: {OUTPUT_DIR.resolve()}")
