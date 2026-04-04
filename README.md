# Optik Okuyucu

Telefon kamerasıyla sinav kagidi okuyan, otomatik notlama yapan ve Excel'e aktaran uygulama.

## Ozellikler
- 4 kose QR kodlu kendi template'ini uret ve oku
- Herhangi bir optik kagidi Gemini AI ile oku (Diger Optik modu)
- El yazisi ad/numara tanima (Gemini Vision)
- Otomatik puanlama ve Excel export
- Grup destegi (A/B/C/D)

## Kurulum

### 1. Backend
```bash
cd backend
pip install -r requirements.txt
```

.env dosyasi olustur:
GEMINI_API_KEY=buraya_kendi_api_keyinizi_yazin

API key almak icin: https://aistudio.google.com -> Get API Key -> Create

Backend baslat:
```bash
cd backend
python -m uvicorn main:app --host 0.0.0.0 --port 8080
```

### 2. APK
- app-debug.apk dosyasini telefona yukleyin
- Bilinmeyen kaynaklardan yuklemeyi acin
- Ayarlardan backend URL girin: http://BILGISAYAR_IP:8080

### 3. Flutter (gelistirme icin)
```bash
cd mobile/optical_reader
flutter pub get
flutter run
```

## Kullanim
1. Yeni Sinav olusturun -> Template uretilir
2. Cevap Anahtari doldurun
3. Template'i yazdirin, ogrencilere dagitin
4. Doldurulan kagitlari Tara ekranindan okutun
5. Sonuclar ve Excel export Gecmis ekraninda

## Teknolojiler
- Backend: Python/FastAPI, OpenCV, pyzbar, Gemini AI
- Frontend: Flutter, Riverpod, Dio
- OCR: Google Gemini 2.0 Flash Vision API
