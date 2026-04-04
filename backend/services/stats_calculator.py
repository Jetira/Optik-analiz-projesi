"""Sinav istatistik hesaplama servisi."""

from __future__ import annotations

import logging
import statistics
from collections import defaultdict

from models.schemas import ExamStats, GradeResult

logger = logging.getLogger(__name__)


def calculate_stats(sinav_id: str, results: list[GradeResult]) -> ExamStats:
    """Puanlama sonuclarindan istatistik hesapla.

    Args:
        sinav_id: Sinav kimlik bilgisi.
        results: Puanlanmis ogrenci sonuclari listesi.

    Returns:
        ExamStats nesnesi.
    """
    n = len(results)
    if n == 0:
        return ExamStats(
            sinav_id=sinav_id,
            toplam_ogrenci=0,
            sinif_ortalamasi=0.0,
            medyan=0.0,
            en_yuksek=0.0,
            en_dusuk=0.0,
            standart_sapma=0.0,
            grup_ortalamalari={},
            soru_dogru_oranlari=[],
            soru_sik_dagilimi=[],
            en_zor_sorular=[],
        )

    puanlar = [r.toplam_puan for r in results]
    ortalama = statistics.mean(puanlar)
    medyan = statistics.median(puanlar)
    en_yuksek = max(puanlar)
    en_dusuk = min(puanlar)
    std_sapma = statistics.pstdev(puanlar) if n > 1 else 0.0

    # -------------------------------------------------------------------------
    # Grup bazli ortalamalar
    # -------------------------------------------------------------------------
    grup_puanlar: dict[str, list[float]] = defaultdict(list)
    for r in results:
        grup_puanlar[r.grup].append(r.toplam_puan)

    grup_ortalamalari = {
        g: round(statistics.mean(p), 2) for g, p in sorted(grup_puanlar.items())
    }

    # -------------------------------------------------------------------------
    # Soru bazli istatistikler
    # -------------------------------------------------------------------------
    soru_sayisi = len(results[0].soru_detay) if results else 0

    soru_dogru = [0] * soru_sayisi
    soru_sik_sayac: list[dict[str, int]] = [defaultdict(int) for _ in range(soru_sayisi)]

    for r in results:
        for det in r.soru_detay:
            idx = det.soru_no - 1
            if idx < 0 or idx >= soru_sayisi:
                continue
            if det.durum == "dogru":
                soru_dogru[idx] += 1
            # Sik dagilimi (bos ve gecersiz dahil)
            if det.verilen_cevap:
                soru_sik_sayac[idx][det.verilen_cevap] += 1
            elif det.durum == "gecersiz":
                soru_sik_sayac[idx]["X"] += 1
            else:
                soru_sik_sayac[idx]["-"] += 1

    soru_dogru_oranlari = [round(d / n, 4) for d in soru_dogru]

    # Sik dagilimini orana cevir
    soru_sik_dagilimi: list[dict[str, float]] = []
    for sayac in soru_sik_sayac:
        toplam = sum(sayac.values()) or 1
        dagim = {k: round(v / toplam, 4) for k, v in sorted(sayac.items())}
        soru_sik_dagilimi.append(dagim)

    # En zor 5 soru (dogru orani en dusuk)
    indexed = list(enumerate(soru_dogru_oranlari))
    indexed.sort(key=lambda x: x[1])
    en_zor = [idx + 1 for idx, _ in indexed[:5]]

    logger.info(
        "Istatistik hesaplandi: sinav=%s, ogrenci=%d, ort=%.2f",
        sinav_id,
        n,
        ortalama,
    )

    return ExamStats(
        sinav_id=sinav_id,
        toplam_ogrenci=n,
        sinif_ortalamasi=round(ortalama, 2),
        medyan=round(medyan, 2),
        en_yuksek=round(en_yuksek, 2),
        en_dusuk=round(en_dusuk, 2),
        standart_sapma=round(std_sapma, 2),
        grup_ortalamalari=grup_ortalamalari,
        soru_dogru_oranlari=soru_dogru_oranlari,
        soru_sik_dagilimi=soru_sik_dagilimi,
        en_zor_sorular=en_zor,
    )
