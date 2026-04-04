# ⚡ Hızlı EC2 Backend Kurulumu

## 🎯 5 Dakikada Kurulum

### 1️⃣ EC2'ye Bağlan
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
```

### 2️⃣ Tek Komutla Kurulum
EC2'de bu komutu çalıştırın:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh && \
sudo sh get-docker.sh && \
sudo usermod -aG docker ubuntu && \
mkdir -p ~/optical-reader-backend && \
echo "✅ Docker kuruldu! Şimdi logout/login yapın ve backend dosyalarını yükleyin."
```

### 3️⃣ Logout ve Tekrar Login
```bash
exit
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
```

### 4️⃣ Backend Dosyalarını Yükle
**Yeni terminal** (Windows):
```powershell
scp -i your-key.pem backend-deploy.zip ubuntu@YOUR_EC2_IP:~/optical-reader-backend/
```

### 5️⃣ Backend'i Başlat
EC2'de:
```bash
cd ~/optical-reader-backend && \
unzip backend-deploy.zip && \
docker build -t optical-backend . && \
docker run -d -p 8080:8080 --name optical-backend --restart unless-stopped optical-backend && \
echo "✅ Backend başlatıldı!" && \
sleep 3 && \
curl http://localhost:8080/health
```

### 6️⃣ Test Et
Tarayıcıda: `http://YOUR_EC2_IP:8080/health`

Görmelisiniz:
```json
{"status":"ok","message":"Optical Reader Backend"}
```

---

## 📱 Mobil Uygulamayı Güncelle

### Seçenek 1: Kod Değişikliği (Kalıcı)

`mobile/optical_reader/lib/services/api_service.dart`:
```dart
final baseUrl = 'http://YOUR_EC2_IP:8080';
```

APK oluştur:
```bash
cd mobile/optical_reader
flutter build apk --release
```

### Seçenek 2: Uygulama İçinden (Geçici)

Ayarlar ekranından backend URL'sini değiştirin.

---

## 🔧 Hızlı Komutlar

```bash
# Durum kontrol
docker ps

# Logları izle
docker logs -f optical-backend

# Yeniden başlat
docker restart optical-backend

# Durdur
docker stop optical-backend

# Başlat
docker start optical-backend
```

---

## ⚠️ Önemli Notlar

1. **Security Group:** Port 8080 açık olmalı
2. **EC2 IP:** Public IP adresini kullanın
3. **Yeniden Başlatma:** EC2 yeniden başlarsa IP değişebilir (Elastic IP kullanın)

---

## 🆘 Sorun mu var?

```bash
# Backend çalışıyor mu?
docker ps

# Logları kontrol et
docker logs optical-backend

# Port açık mı?
sudo netstat -tulpn | grep 8080

# Health check
curl http://localhost:8080/health
```

Hala sorun varsa `EC2_KURULUM_REHBERI.md` dosyasına bakın.
