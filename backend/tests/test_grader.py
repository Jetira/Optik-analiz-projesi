"""Puanlama motoru testleri.

Test 1: 20 soru, farkli puanlar (ilk 10=5p, son 10=10p), 15 dogru + 3 yanlis + 2 bos
Test 2: Gecersiz isaretleme iceren senaryo
Test 3: Cevap anahtari kaydet/yukle dongusu
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from models.schemas import (
    AnswerKey,
    ScanResult,
    StudentAnswer,
    GradeResult,
)
from services.grader import grade_exam


def test_mixed_results():
    """15 dogru + 3 yanlis + 2 bos, farkli puanlar."""
    soru_sayisi = 20
    # ilk 10 soru 5p, son 10 soru 10p
    puanlar = [5.0] * 10 + [10.0] * 10

    # Dogru cevaplar: 1-20 arasi A,B,C,D dongusunde
    dogru_cevaplar = []
    choices = ["A", "B", "C", "D"]
    for i in range(soru_sayisi):
        dogru_cevaplar.append(choices[i % 4])

    answer_key = AnswerKey(
        sinav_id="test-grade",
        grup="A",
        cevaplar=dogru_cevaplar,
        puanlar=puanlar,
    )

    # Ogrenci cevaplari:
    # Soru 1-15: dogru (dogru cevabi ver)
    # Soru 16-18: yanlis (farkli sik)
    # Soru 19-20: bos
    ogrenci_cevaplar: list[StudentAnswer] = []
    for q in range(1, soru_sayisi + 1):
        if q <= 15:
            cevap = dogru_cevaplar[q - 1]
        elif q <= 18:
            # Yanlis: dogru cevaptan farkli bir sik sec
            dogru = dogru_cevaplar[q - 1]
            cevap = "D" if dogru != "D" else "A"
        else:
            cevap = None

        ogrenci_cevaplar.append(StudentAnswer(
            soru_no=q,
            cevap=cevap,
            gecersiz=False,
        ))

    scan = ScanResult(
        ogrenci_ad="Ahmet Yilmaz",
        ogrenci_no="12345",
        sinav_id="test-grade",
        grup="A",
        soru_sayisi=soru_sayisi,
        sik_sayisi=4,
        cevaplar=ogrenci_cevaplar,
    )

    result = grade_exam(scan, answer_key)

    # Dogrulama
    assert result.dogru_sayisi == 15
    assert result.yanlis_sayisi == 3
    assert result.bos_sayisi == 2
    assert result.gecersiz_sayisi == 0

    # Puan hesabi:
    # Dogru sorular: 1-10 arasi 10 dogru * 5p = 50, 11-15 arasi 5 dogru * 10p = 50
    # Toplam = 100
    assert result.toplam_puan == 100.0

    # Maks puan: 10*5 + 10*10 = 150
    assert result.maks_puan == 150.0

    # Detay kontrolu
    assert len(result.soru_detay) == soru_sayisi
    assert result.soru_detay[0].durum == "dogru"
    assert result.soru_detay[0].alinan_puan == 5.0
    assert result.soru_detay[15].durum == "yanlis"
    assert result.soru_detay[15].alinan_puan == 0.0
    assert result.soru_detay[18].durum == "bos"

    assert result.ogrenci_ad == "Ahmet Yilmaz"
    assert result.ogrenci_no == "12345"

    print(
        f"PASSED: Karisik sonuclar — "
        f"{result.dogru_sayisi}D {result.yanlis_sayisi}Y "
        f"{result.bos_sayisi}B {result.gecersiz_sayisi}G — "
        f"{result.toplam_puan}/{result.maks_puan}p"
    )


def test_with_invalid():
    """Gecersiz isaretleme senaryosu."""
    soru_sayisi = 10
    puanlar = [10.0] * soru_sayisi
    dogru_cevaplar = ["A"] * soru_sayisi

    answer_key = AnswerKey(
        sinav_id="test-inv",
        grup="B",
        cevaplar=dogru_cevaplar,
        puanlar=puanlar,
    )

    cevaplar = [
        StudentAnswer(soru_no=1, cevap="A"),                  # dogru
        StudentAnswer(soru_no=2, cevap="A"),                  # dogru
        StudentAnswer(soru_no=3, cevap="A"),                  # dogru
        StudentAnswer(soru_no=4, cevap="B"),                  # yanlis
        StudentAnswer(soru_no=5, cevap="B"),                  # yanlis
        StudentAnswer(soru_no=6, cevap=None),                 # bos
        StudentAnswer(soru_no=7, cevap=None, gecersiz=True),  # gecersiz
        StudentAnswer(soru_no=8, cevap=None, gecersiz=True),  # gecersiz
        StudentAnswer(soru_no=9, cevap="A"),                  # dogru
        StudentAnswer(soru_no=10, cevap=None),                # bos
    ]

    scan = ScanResult(
        sinav_id="test-inv",
        grup="B",
        soru_sayisi=soru_sayisi,
        sik_sayisi=4,
        cevaplar=cevaplar,
    )

    result = grade_exam(scan, answer_key)

    assert result.dogru_sayisi == 4
    assert result.yanlis_sayisi == 2
    assert result.bos_sayisi == 2
    assert result.gecersiz_sayisi == 2
    assert result.toplam_puan == 40.0
    assert result.maks_puan == 100.0

    # Gecersiz soru detayi
    assert result.soru_detay[6].durum == "gecersiz"
    assert result.soru_detay[6].alinan_puan == 0.0

    print(
        f"PASSED: Gecersiz senaryo — "
        f"{result.dogru_sayisi}D {result.yanlis_sayisi}Y "
        f"{result.bos_sayisi}B {result.gecersiz_sayisi}G — "
        f"{result.toplam_puan}/{result.maks_puan}p"
    )


def test_answer_key_crud():
    """Cevap anahtari kaydet/yukle."""
    import json
    from routers.answer_key import _key_path, DATA_DIR

    key = AnswerKey(
        sinav_id="test-crud",
        grup="A",
        cevaplar=["A", "B", "C", "D", "A"],
        puanlar=[20.0, 20.0, 20.0, 20.0, 20.0],
    )

    # Kaydet
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    path = _key_path(key.sinav_id, key.grup)
    path.write_text(key.model_dump_json(indent=2), encoding="utf-8")
    assert path.exists()

    # Yukle
    loaded = json.loads(path.read_text(encoding="utf-8"))
    loaded_key = AnswerKey(**loaded)
    assert loaded_key.sinav_id == key.sinav_id
    assert loaded_key.grup == key.grup
    assert loaded_key.cevaplar == key.cevaplar
    assert loaded_key.puanlar == key.puanlar

    # Temizle
    path.unlink()

    print("PASSED: Cevap anahtari CRUD")


def test_all_correct():
    """Tum sorular dogru — tam puan kontrolu."""
    soru_sayisi = 5
    puanlar = [20.0] * soru_sayisi
    cevaplar_dogru = ["A", "B", "C", "D", "A"]

    answer_key = AnswerKey(
        sinav_id="test-full",
        grup="A",
        cevaplar=cevaplar_dogru,
        puanlar=puanlar,
    )

    scan = ScanResult(
        sinav_id="test-full",
        grup="A",
        soru_sayisi=soru_sayisi,
        sik_sayisi=4,
        cevaplar=[
            StudentAnswer(soru_no=i + 1, cevap=cevaplar_dogru[i])
            for i in range(soru_sayisi)
        ],
    )

    result = grade_exam(scan, answer_key)
    assert result.toplam_puan == result.maks_puan == 100.0
    assert result.dogru_sayisi == 5
    assert result.yanlis_sayisi == 0
    assert result.bos_sayisi == 0

    print(f"PASSED: Tam puan — {result.toplam_puan}/{result.maks_puan}p")


if __name__ == "__main__":
    test_mixed_results()
    test_with_invalid()
    test_answer_key_crud()
    test_all_correct()
    print("\nTum puanlama testleri gecti!")
