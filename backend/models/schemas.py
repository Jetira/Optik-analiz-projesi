"""Pydantic modeller."""

from __future__ import annotations

import uuid
from typing import Union

from pydantic import BaseModel, Field, field_validator, model_validator


# ---------------------------------------------------------------------------
# Exam configuration
# ---------------------------------------------------------------------------


class ExamConfig(BaseModel):
    """Sinav yapilandirmasi — template uretimi ve cevap anahtari icin."""

    sinav_id: str | None = None
    sinav_adi: str = Field(..., min_length=1, max_length=200)
    soru_sayisi: int = Field(..., ge=1, le=100)
    sik_sayisi: int = Field(..., ge=4, le=5)
    puanlar: Union[list[float], float] = Field(
        ...,
        description="Her sorunun puani (liste) veya tek puan (tum sorulara esit)",
    )
    grup_sayisi: int = Field(default=1, ge=1, le=4)
    gruplar: list[str] | None = None

    @model_validator(mode="after")
    def _fill_defaults(self) -> "ExamConfig":
        if not self.sinav_id:
            self.sinav_id = uuid.uuid4().hex[:8]

        all_groups = ["A", "B", "C", "D"]
        if not self.gruplar:
            self.gruplar = all_groups[: self.grup_sayisi]
        if len(self.gruplar) != self.grup_sayisi:
            raise ValueError("gruplar listesi grup_sayisi ile eslesmiyor")

        if isinstance(self.puanlar, (int, float)):
            self.puanlar = [float(self.puanlar)] * self.soru_sayisi
        if len(self.puanlar) != self.soru_sayisi:
            raise ValueError("puanlar listesi soru_sayisi ile eslesmiyor")

        return self

    @field_validator("sik_sayisi")
    @classmethod
    def _check_sik(cls, v: int) -> int:
        if v not in (4, 5):
            raise ValueError("sik_sayisi 4 veya 5 olmali")
        return v


# ---------------------------------------------------------------------------
# Answer key
# ---------------------------------------------------------------------------


class AnswerKey(BaseModel):
    """Bir grup icin cevap anahtari."""

    sinav_id: str
    grup: str
    cevaplar: list[str]
    puanlar: list[float]

    @model_validator(mode="after")
    def _validate_lengths(self) -> "AnswerKey":
        if len(self.cevaplar) != len(self.puanlar):
            raise ValueError("cevaplar ve puanlar listesi ayni uzunlukta olmali")
        return self


# ---------------------------------------------------------------------------
# Scan results
# ---------------------------------------------------------------------------


class StudentAnswer(BaseModel):
    """Tek bir sorunun tarama sonucu."""

    soru_no: int
    cevap: str | None = None
    gecersiz: bool = False


class ScanResult(BaseModel):
    """Tek bir kagit tarama sonucu."""

    ogrenci_ad: str | None = None
    ogrenci_no: str | None = None
    sinav_id: str
    grup: str
    soru_sayisi: int
    sik_sayisi: int
    cevaplar: list[StudentAnswer]


class BatchError(BaseModel):
    """Toplu taramada basarisiz olan dosya."""

    dosya_adi: str
    hata: str


class BatchScanResponse(BaseModel):
    """Toplu tarama yaniti."""

    basarili: list[ScanResult]
    hatali: list[BatchError]


# ---------------------------------------------------------------------------
# Grading
# ---------------------------------------------------------------------------


class QuestionDetail(BaseModel):
    """Soru bazli puanlama detayi."""

    soru_no: int
    verilen_cevap: str | None
    dogru_cevap: str
    puan: float
    alinan_puan: float
    durum: str  # "dogru" | "yanlis" | "bos" | "gecersiz"


class GradeResult(BaseModel):
    """Puanlama sonucu."""

    ogrenci_ad: str | None = None
    ogrenci_no: str | None = None
    sinav_id: str
    grup: str
    soru_detay: list[QuestionDetail]
    toplam_puan: float
    maks_puan: float
    dogru_sayisi: int
    yanlis_sayisi: int
    bos_sayisi: int
    gecersiz_sayisi: int


# ---------------------------------------------------------------------------
# Statistics
# ---------------------------------------------------------------------------


class ExamStats(BaseModel):
    """Sinav istatistikleri."""

    sinav_id: str
    toplam_ogrenci: int
    sinif_ortalamasi: float
    medyan: float
    en_yuksek: float
    en_dusuk: float
    standart_sapma: float
    grup_ortalamalari: dict[str, float]
    soru_dogru_oranlari: list[float]
    soru_sik_dagilimi: list[dict[str, float]]
    en_zor_sorular: list[int]
