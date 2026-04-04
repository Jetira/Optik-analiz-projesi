"""Puanlama motoru.

Tarama sonucunu (ScanResult) cevap anahtariyla (AnswerKey) karsilastirip
soru bazli detayli puanlama yapar.
"""

from __future__ import annotations

import logging

from models.schemas import (
    AnswerKey,
    GradeResult,
    QuestionDetail,
    ScanResult,
)

logger = logging.getLogger(__name__)


def grade_exam(scan_result: ScanResult, answer_key: AnswerKey) -> GradeResult:
    """Tarama sonucunu cevap anahtariyla puanla.

    Args:
        scan_result: Bubble okuma sonucu.
        answer_key: Dogru cevaplar ve soru puanlari.

    Returns:
        Soru bazli detayli puanlama sonucu.
    """
    soru_detay: list[QuestionDetail] = []
    toplam_puan = 0.0
    maks_puan = 0.0
    dogru = 0
    yanlis = 0
    bos = 0
    gecersiz = 0

    for sa in scan_result.cevaplar:
        idx = sa.soru_no - 1  # 0-tabanli index
        if idx < 0 or idx >= len(answer_key.cevaplar):
            continue

        dogru_cevap = answer_key.cevaplar[idx]
        puan = answer_key.puanlar[idx]
        maks_puan += puan

        if sa.gecersiz:
            durum = "gecersiz"
            alinan = 0.0
            gecersiz += 1
        elif sa.cevap is None:
            durum = "bos"
            alinan = 0.0
            bos += 1
        elif sa.cevap == dogru_cevap:
            durum = "dogru"
            alinan = puan
            dogru += 1
        else:
            durum = "yanlis"
            alinan = 0.0
            yanlis += 1

        toplam_puan += alinan

        soru_detay.append(QuestionDetail(
            soru_no=sa.soru_no,
            verilen_cevap=sa.cevap,
            dogru_cevap=dogru_cevap,
            puan=puan,
            alinan_puan=alinan,
            durum=durum,
        ))

    logger.info(
        "Puanlama: %d dogru, %d yanlis, %d bos, %d gecersiz — %.1f/%.1f",
        dogru, yanlis, bos, gecersiz, toplam_puan, maks_puan,
    )

    return GradeResult(
        ogrenci_ad=scan_result.ogrenci_ad,
        ogrenci_no=scan_result.ogrenci_no,
        sinav_id=scan_result.sinav_id,
        grup=scan_result.grup,
        soru_detay=soru_detay,
        toplam_puan=toplam_puan,
        maks_puan=maks_puan,
        dogru_sayisi=dogru,
        yanlis_sayisi=yanlis,
        bos_sayisi=bos,
        gecersiz_sayisi=gecersiz,
    )
