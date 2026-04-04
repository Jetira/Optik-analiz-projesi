# CLAUDE.md — Optik Okuyucu Mobil Uygulama v2

## Proje Özeti

Telefon kamerasıyla sınav kağıdı okuyan, otomatik notlama yapan ve sonuçları Excel'e aktaran Flutter + Python/FastAPI uygulaması. Kağıdın 4 köşesinde QR kod bulunur (hizalama + metadata). Öğrenci ad/numarası OCR ile, bubble sheet (çoktan seçmeli) ise görüntü işleme ile okunur. Sınav grubu (A/B/C/D) desteği, toplu tarama modu ve soru bazlı istatistik içerir.

## Proje Yapısı

```
optical-reader/
├── backend/
│   ├── main.py                    # FastAPI app entry point
│   ├── config.py                  # Sabit değerler, eşikler, ayarlar
│   ├── requirements.txt
│   ├── routers/
│   │   ├── scan.py                # POST /api/scan — görüntü işleme pipeline
│   │   ├── scan_batch.py          # POST /api/scan/batch — toplu tarama
│   │   ├── answer_key.py          # POST /api/answer-key — cevap anahtarı CRUD
│   │   ├── grade.py               # POST /api/grade — puanlama
│   │   ├── stats.py               # GET /api/stats/{sinav_id} — istatistikler
│   │   ├── export.py              # GET /api/export/{sinav_id} — Excel export
│   │   └── template.py            # POST /api/template — template üret
│   ├── services/
│   │   ├── qr_detector.py         # pyzbar ile 4 köşe QR tespiti
│   │   ├── perspective.py         # cv2 perspektif düzeltme
│   │   ├── bubble_reader.py       # Bubble detection + okuma
│   │   ├── ocr_reader.py          # Tesseract OCR (öğrenci ad/no)
│   │   ├── grader.py              # Puanlama motoru (grup bazlı)
│   │   ├── stats_calculator.py    # İstatistik hesaplama
│   │   ├── excel_writer.py        # openpyxl ile Excel oluşturma (2 sheet)
│   │   └── template_generator.py  # Sınav kağıdı template oluşturucu
│   ├── models/
│   │   └── schemas.py             # Pydantic modeller
│   ├── data/                      # Cevap anahtarları + tarama sonuçları JSON
│   └── tests/
│       ├── test_qr.py
│       ├── test_bubble.py
│       ├── test_ocr.py
│       ├── test_grader.py
│       └── test_stats.py
├── mobile/
│   └── optical_reader/            # Flutter projesi
│       └── lib/
│           ├── main.dart
│           ├── app/
│           │   ├── router.dart             # go_router
│           │   └── theme.dart
│           ├── constants/
│           │   └── strings.dart            # Tüm sabit stringler
│           ├── providers/
│           │   ├── exam_provider.dart       # Sınav state
│           │   ├── scan_provider.dart       # Tarama state (tek + toplu)
│           │   ├── result_provider.dart     # Sonuç state
│           │   └── stats_provider.dart      # İstatistik state
│           ├── services/
│           │   └── api_service.dart         # Dio ile backend haberleşme
│           ├── models/
│           │   ├── exam.dart
│           │   ├── scan_result.dart
│           │   ├── student_result.dart
│           │   └── exam_stats.dart
│           └── screens/
│               ├── home_screen.dart
│               ├── create_exam_screen.dart   # Sınav oluştur + grup + puan
│               ├── answer_key_screen.dart    # Grup bazlı cevap anahtarı
│               ├── scan_screen.dart          # Tek çekim (kamera veya galeri)
│               ├── batch_scan_screen.dart    # Toplu tarama (kamera veya galeriden çoklu)
│               ├── result_screen.dart        # Soru bazlı sonuç
│               ├── history_screen.dart       # Tarama geçmişi
│               ├── stats_screen.dart         # İstatistik + grafikler
│               └── settings_screen.dart      # Backend IP/port, tema
├── roadmap.txt
└── CLAUDE.md
```

## Teknoloji Stack

### Backend (Python 3.11+)
- **FastAPI** — REST API framework
- **OpenCV (cv2)** — Görüntü işleme, perspektif düzeltme, bubble detection
- **pyzbar** — QR kod okuma
- **pytesseract** — El yazısı OCR (Tesseract, lang=tur)
- **openpyxl** — Excel .xlsx oluşturma (2 sheet: sonuçlar + istatistik)
- **qrcode** — QR kod üretimi (template için)
- **numpy** — Matris/piksel işlemleri
- **Pillow** — Görüntü manipülasyonu
- **Pydantic** — Veri doğrulama

### Frontend (Flutter/Dart)
- **Riverpod** — State management
- **Dio** — HTTP client
- **camera** — Kamera erişimi
- **image_picker** — Galeriden fotoğraf seçimi
- **go_router** — Navigasyon
- **path_provider** — Dosya sistemi
- **share_plus** — Excel paylaşımı
- **fl_chart** — İstatistik grafikleri (bar chart, pie chart)

## Kritik Teknik Detaylar

### 4 Köşe QR Kod Sistemi
- Her köşedeki QR aynı JSON metadata'yı taşır:
  ```json
  {
    "sinav_id": "mat101-vize",
    "soru_sayisi": 20,
    "sik_sayisi": 4,
    "grup": "A",
    "versiyon": 1
  }
  ```
- QR kodlar hizalama referans noktaları olarak kullanılır
- 4 QR'ın merkez koordinatları → `cv2.getPerspectiveTransform()` → düzeltilmiş görüntü
- En az 3 QR okunmalı, 4. yoksa 3 noktadan tahmin edilir

### Sınav Grubu Sistemi (A/B/C/D)
- Her grup için ayrı template üretilir (QR'daki "grup" alanı farklı)
- Her grup için ayrı cevap anahtarı kaydedilir
- Tarama sırasında QR'dan grup otomatik okunur → doğru cevap anahtarı seçilir
- Template üzerinde grup harfi büyük ve görünür şekilde basılır
- Soru sırası gruplar arasında farklı olabilir (hoca belirler)

### Bubble Detection Pipeline
0. Flutter tarafında image resize (1200-1600px genişlik, JPEG q80, ~200-400KB) — upload hızı için kritik
1. Perspektif düzeltilmiş görüntüyü al
2. Bubble grid bölgesini crop et (QR pozisyonlarına göre sabit oran)
3. Grayscale → GaussianBlur(5,5) → adaptiveThreshold
4. findContours → dairesel contourları filtrele (circularity > 0.7)
5. Grid pozisyonuna göre sırala (satır = soru, sütun = şık)
6. Her bubble için doluluk oranı hesapla (countNonZero / alan)
7. Doluluk > 0.5 → işaretli, birden fazla → geçersiz, hiçbiri → boş

### Dinamik Şık Sayısı
- Sınav 4 şıklıysa: A, B, C, D
- Sınav 5 şıklıysa: A, B, C, D, E
- Bu bilgi QR metadata'dan okunur, bubble grid buna göre parse edilir

### Puan Sistemi
- Her soruya ayrı puan atanabilir (örn: [5, 5, 10, 10, 20])
- Tek puan da atanabilir (tüm sorular eşit)
- Doğru = tam puan, Yanlış = 0, Boş = 0, Geçersiz = 0
- Negatif puanlama YOK (şimdilik)

### Toplu Tarama Modu
- Kameradan çek VEYA galeriden çoklu seç → Flutter'da resize (1200-1600px genişlik, JPEG quality 80, ~200-400KB) → backend'e gönder → sonuç toast/badge ile göster
- Beklenen hız: kağıt başı ~2-3 saniye (30 kağıt ≈ 1.5 dakika)
- Onay ekranı yok, hemen sonraki kağıda geç
- Tarama tamamlanınca toplu sonuç listesi göster
- Hatalı okumalar (QR bulunamadı, belirsiz bubble) ayrı işaretlenir
- Hatalı olanlar tekrar çekilebilir

### Görüntü Kaynağı Seçimi
- Tek tarama ve toplu tarama ekranlarında alt sheet veya toggle: Kamera / Galeri
- Galeri modu development/test için çok kullanışlı (yazıcı olmadan template'i ekranda açıp screenshot al, paint'te doldur, galeriden yükle)
- image_picker paketi: tek seç (ImageSource.gallery) veya çoklu seç (pickMultiImage)

### Excel Çıktısı (.xlsx — 2 Sheet)

**Sheet 1 — Sonuçlar:**
- Başlık: Öğrenci Adı | Öğrenci No | Grup | S1 (5p) | S2 (5p) | ... | Toplam | Maks
- Doğru hücreler: yeşil arka plan + şık harfi
- Yanlış hücreler: kırmızı arka plan + şık harfi
- Boş hücreler: "-"
- Geçersiz hücreler: sarı arka plan + "X"
- Gruplara göre sıralı

**Sheet 2 — İstatistikler:**
- Sınıf ortalaması, medyan, en yüksek, en düşük, standart sapma
- Soru bazlı doğru oranı (S1: %85, S2: %40...)
- Soru bazlı şık dağılımı (S1 → A: %15, B: %60, C: %20, D: %5)
- Grup bazlı ortalama karşılaştırma
- En çok yanlış yapılan TOP 5 soru

### App İçi İstatistik Ekranı
- Bar chart: soru bazlı doğru oranları
- Pie chart: sınıf geneli doğru/yanlış/boş dağılımı
- Grup karşılaştırma barları
- fl_chart paketi ile

### Sınav Kağıdı Template
- A4 boyut, yazdırılabilir
- Üst kısım: Sınav adı + Grup harfi (büyük) + öğrenci ad/no yazma alanı (çerçeveli)
- Orta: Bubble grid (soru numaraları + daireler)
- 4 köşe: QR kodlar
- Çıktı formatı: PNG (varsayılan) veya PDF
- Çoklu grup: tek komutla A,B,C,D hepsini üretir

## API Endpointleri

```
POST   /api/scan                — Tek fotoğraf yükle → QR + bubble + OCR → sonuç JSON
POST   /api/scan/batch          — Birden fazla fotoğraf yükle → toplu sonuç
POST   /api/answer-key          — Cevap anahtarı + soru puanları kaydet (grup bazlı)
GET    /api/answer-key/{id}     — Cevap anahtarı getir (query param: ?grup=A)
POST   /api/grade               — Okunan cevapları puanla (grup otomatik QR'dan gelir)
GET    /api/stats/{sinav_id}    — İstatistik JSON (app içi grafikler için)
GET    /api/export/{sinav_id}   — Excel dosyası indir (2 sheet)
POST   /api/template            — Sınav kağıdı template üret (tüm gruplar)
GET    /health                  — Sağlık kontrolü
```

## Pydantic Modeller

```python
class ExamConfig(BaseModel):
    sinav_id: str
    sinav_adi: str
    soru_sayisi: int          # 1-100
    sik_sayisi: int           # 4 veya 5
    puanlar: list[float]      # Her sorunun puanı
    grup_sayisi: int           # 1-4, varsayılan 1
    gruplar: list[str]         # ["A"], ["A","B"], ["A","B","C","D"]

class AnswerKey(BaseModel):
    sinav_id: str
    grup: str                  # "A", "B", "C", "D"
    cevaplar: list[str]        # ["A", "B", "C", ...]
    puanlar: list[float]       # [5, 5, 10, ...]

class ScanResult(BaseModel):
    ogrenci_ad: str | None
    ogrenci_no: str | None
    grup: str                  # QR'dan okunan grup
    cevaplar: list[StudentAnswer]

class StudentAnswer(BaseModel):
    soru_no: int
    cevap: str | None          # "A", "B", ... veya None (boş)
    gecersiz: bool             # Birden fazla işaretleme

class GradeResult(BaseModel):
    ogrenci_ad: str | None
    ogrenci_no: str | None
    grup: str
    soru_detay: list[QuestionDetail]
    toplam_puan: float
    maks_puan: float
    dogru_sayisi: int
    yanlis_sayisi: int
    bos_sayisi: int
    gecersiz_sayisi: int

class QuestionDetail(BaseModel):
    soru_no: int
    verilen_cevap: str | None
    dogru_cevap: str
    puan: float
    alinan_puan: float
    durum: str                # "dogru" | "yanlis" | "bos" | "gecersiz"

class ExamStats(BaseModel):
    sinav_id: str
    toplam_ogrenci: int
    sinif_ortalamasi: float
    medyan: float
    en_yuksek: float
    en_dusuk: float
    standart_sapma: float
    grup_ortalamalari: dict[str, float]       # {"A": 72.5, "B": 68.3}
    soru_dogru_oranlari: list[float]          # [0.85, 0.40, ...]
    soru_sik_dagilimi: list[dict[str, float]] # [{"A": 0.15, "B": 0.60, ...}, ...]
    en_zor_sorular: list[int]                 # [5, 12, 18, 3, 7] (TOP 5)

class BatchScanResponse(BaseModel):
    basarili: list[ScanResult]
    hatali: list[BatchError]

class BatchError(BaseModel):
    dosya_adi: str
    hata: str                 # "QR okunamadı", "Bubble belirsiz" vs.
```

## Kodlama Kuralları

### Genel
- Değişken/fonksiyon adları İngilizce, kullanıcıya dönük stringler Türkçe olabilir
- Her dosya tek sorumluluk (SRP)
- Type hint'ler zorunlu (Python + Dart)
- Docstring zorunlu (public fonksiyonlar)

### Python Backend
- async endpoint'ler kullan
- Her servis bağımsız test edilebilir olmalı
- OpenCV işlemleri try-except içinde, hata durumunda anlamlı HTTP error dön
- Loglama: logging modülü, print() KULLANMA
- Sabit değerler config.py'de topla
- JSON dosya bazlı storage (SQLite opsiyonel, MVP'de gerek yok)

### Flutter
- Riverpod ile state yönetimi (ConsumerWidget / ConsumerStatefulWidget)
- go_router ile navigasyon
- Tüm ekranlar screens/ altında
- API çağrıları services/api_service.dart üzerinden
- Hardcoded string yok, constants/strings.dart'ta topla
- MaterialApp tema: app/theme.dart'ta merkezi

### Önemli Eşik Değerleri (config.py)
```python
BUBBLE_FILL_THRESHOLD = 0.5      # Bu üstü = işaretli
BUBBLE_CIRCULARITY_MIN = 0.7     # Daire tanıma eşiği
QR_MIN_DETECTED = 3              # En az 3 QR okunmalı
GAUSSIAN_BLUR_KERNEL = (5, 5)
ADAPTIVE_THRESH_BLOCK = 11
ADAPTIVE_THRESH_C = 2
MAX_QUESTIONS = 100
MAX_GROUPS = 4
VALID_CHOICES_4 = ["A", "B", "C", "D"]
VALID_CHOICES_5 = ["A", "B", "C", "D", "E"]
# Flutter tarafı (api_service.dart'ta)
IMAGE_RESIZE_WIDTH = 1600         # px, gönderim öncesi
IMAGE_JPEG_QUALITY = 80           # 0-100
```

## Deployment

### Demo Senaryosu (Local Network)
- Laptop'ta backend çalışır: `uvicorn main:app --host 0.0.0.0 --port 8000`
- Telefon ve laptop aynı WiFi ağında
- Flutter app ayarlarından laptop'un local IP'si girilir (örn: `192.168.1.x:8000`)
- Backend'e erişim doğrulaması: /health endpoint'e ping

### İleride (Opsiyonel)
- VPS'e deploy (Docker + nginx)
- Demo için gerek yok

## Fazlar (Referans: roadmap.txt)

- **Faz 0**: Proje iskeleti, bağımlılıklar, bağlantı testi
- **Faz 1**: Sınav kağıdı template oluşturucu (grup desteği dahil)
- **Faz 2**: Görüntü işleme pipeline (QR + perspektif + bubble detection) ← EN KRİTİK
- **Faz 3**: OCR + grup bazlı puanlama motoru
- **Faz 4**: Flutter mobil uygulama (tek çekim + toplu tarama)
- **Faz 5**: Excel export (2 sheet) + istatistik ekranı (fl_chart)
- **Faz 6**: Test + polish + demo

## Dikkat Edilecekler
- Bubble detection'da en büyük risk: farklı ışık koşulları ve kağıt kalitesi. Adaptive threshold kullan, global threshold KULLANMA.
- QR kod boyutu en az 2x2 cm olmalı, aksi halde kamera uzaktan okuyamaz.
- Perspektif düzeltme başarısız olursa (QR bulunamazsa), kullanıcıya tekrar çekmesini söyle, zorla okumaya çalışma.
- Template'deki bubble boyutları ve grid spacing sabit ve bilinen değerler olmalı. Perspektif düzeltme sonrası bu değerler piksel cinsinden hesaplanabilir.
- OCR Türkçe karakter desteği için Tesseract'ta `lang=tur` parametresi şart.
- Toplu taramada hız önemli: backend tarafında gereksiz I/O'yu minimize et, görüntü işleme pipeline'ı optimize et.
- Grup cevap anahtarı eşleşmesi QR'dan otomatik gelir — kullanıcıdan seçmesi istenmez, hata payı azalır.
- Excel'de geçersiz (birden fazla işaretleme) hücreler sarı arka plan + "X" ile gösterilir.
- PERFORMANS: Telefon kamerası 5-15MB fotoğraf çeker. Backend'e göndermeden önce Flutter tarafında mutlaka resize et (1200-1600px). Bu 10x hız farkı yaratır. Resize olmadan toplu tarama kullanılamaz derecede yavaşlar.
- Tesseract OCR pipeline'daki en yavaş adım (~0.5-1sn). Ad/no alanı küçük crop olduğu için kabul edilebilir. İleride Google ML Kit (on-device) ile değiştirilebilir ama APK ~10MB şişer.
