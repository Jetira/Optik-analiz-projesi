# 🚀 EC2 Backend Kurulum Rehberi

## Ön Hazırlık

### 1. EC2 Security Group Ayarları
AWS Console → EC2 → Security Groups → Instance'ınızın Security Group'u

**Inbound Rules ekleyin:**
- Type: Custom TCP
- Port: 8080
- Source: 0.0.0.0/0 (veya kendi IP'niz)
- Description: Backend API

### 2. SSH Key Hazırlığı
`.pem` dosyanızın yolunu not edin (örn: `C:\Users\YourName\Downloads\your-key.pem`)

---

## Kurulum Adımları

### Adım 1: EC2'ye Bağlanın

```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
```

**Not:** `YOUR_EC2_IP` yerine EC2 instance'ınızın Public IP adresini yazın.

### Adım 2: Kurulum Scriptini Çalıştırın

EC2'de:
```bash
# Kurulum scriptini oluştur
cat > setup.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Optical Reader Backend Kurulumu..."

# Sistem güncelleme
sudo apt update
sudo apt upgrade -y

# Docker kurulumu
sudo apt install -y docker.io unzip
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Backend dizini
mkdir -p ~/optical-reader-backend
cd ~/optical-reader-backend

echo "✅ Temel kurulum tamamlandı!"
echo "📝 Şimdi backend dosyalarını yükleyin."
EOF

chmod +x setup.sh
./setup.sh
```

### Adım 3: Backend Dosyalarını Yükleyin

**Yeni bir terminal açın** (Windows PowerShell veya CMD):

```powershell
# Backend zip dosyasını EC2'ye yükle
scp -i your-key.pem backend-deploy.zip ubuntu@YOUR_EC2_IP:~/optical-reader-backend/
```

### Adım 4: Backend'i Çalıştırın

EC2 SSH terminalinde:

```bash
cd ~/optical-reader-backend

# Zip dosyasını aç
unzip backend-deploy.zip

# Docker image oluştur
sudo docker build -t optical-backend .

# Container'ı çalıştır
sudo docker run -d \
  -p 8080:8080 \
  --name optical-backend \
  --restart unless-stopped \
  optical-backend

# Logları kontrol et
sudo docker logs optical-backend

# Çalışıyor mu test et
curl http://localhost:8080/health
```

**Beklenen Çıktı:**
```json
{"status":"ok","message":"Optical Reader Backend"}
```

### Adım 5: Dışarıdan Erişimi Test Edin

Tarayıcınızda veya Postman'de:
```
http://YOUR_EC2_IP:8080/health
```

---

## Mobil Uygulamayı Güncelleme

### Backend URL'sini Değiştirin

`mobile/optical_reader/lib/services/api_service.dart` dosyasında:

```dart
// Eski
final baseUrl = 'http://localhost:8080';

// Yeni
final baseUrl = 'http://YOUR_EC2_IP:8080';
```

Veya `.env` dosyası kullanıyorsanız:
```
API_BASE_URL=http://YOUR_EC2_IP:8080
```

### Yeni APK Oluşturun

```bash
cd mobile/optical_reader
flutter build apk --release
```

---

## Faydalı Komutlar

### Container Yönetimi
```bash
# Container durumunu kontrol et
sudo docker ps

# Logları izle
sudo docker logs -f optical-backend

# Container'ı durdur
sudo docker stop optical-backend

# Container'ı başlat
sudo docker start optical-backend

# Container'ı yeniden başlat
sudo docker restart optical-backend

# Container'ı sil
sudo docker rm -f optical-backend
```

### Backend Güncelleme
```bash
# Yeni backend dosyalarını yükle
scp -i your-key.pem backend-deploy.zip ubuntu@YOUR_EC2_IP:~/optical-reader-backend/

# EC2'de
cd ~/optical-reader-backend
sudo docker stop optical-backend
sudo docker rm optical-backend
unzip -o backend-deploy.zip
sudo docker build -t optical-backend .
sudo docker run -d -p 8080:8080 --name optical-backend --restart unless-stopped optical-backend
```

### Sistem Kaynakları
```bash
# Disk kullanımı
df -h

# RAM kullanımı
free -h

# Docker disk kullanımı
sudo docker system df

# Eski image'ları temizle
sudo docker system prune -a
```

---

## Sorun Giderme

### Backend Çalışmıyor
```bash
# Logları kontrol et
sudo docker logs optical-backend

# Container içine gir
sudo docker exec -it optical-backend bash

# Port dinleniyor mu?
sudo netstat -tulpn | grep 8080
```

### Bağlantı Hatası
1. Security Group'ta port 8080 açık mı?
2. EC2 instance çalışıyor mu?
3. Backend container çalışıyor mu? (`sudo docker ps`)
4. Firewall kapalı mı? (`sudo ufw status`)

### Yavaş Çalışma
- Instance type'ı yükseltin (t2.small → t2.medium)
- RAM kullanımını kontrol edin (`free -h`)
- Disk alanını kontrol edin (`df -h`)

---

## Güvenlik Önerileri

### 1. HTTPS Kullanın (Opsiyonel)
- Let's Encrypt ile ücretsiz SSL sertifikası
- Nginx reverse proxy kullanın
- Domain adı gerekir

### 2. API Key Ekleyin
Backend'e authentication ekleyin

### 3. Rate Limiting
Aşırı istek yapılmasını engelleyin

### 4. Firewall
```bash
sudo ufw allow 22
sudo ufw allow 8080
sudo ufw enable
```

---

## Maliyet Optimizasyonu

### EC2 Instance Seçimi
- **Geliştirme:** t2.micro (ücretsiz tier)
- **Üretim:** t2.small veya t3.small
- **Yoğun kullanım:** t3.medium

### Otomatik Kapatma
Kullanılmadığında instance'ı durdurun (Stop, Terminate değil)

---

## Yedekleme

### Backend Verilerini Yedekle
```bash
# data klasörünü yedekle
cd ~/optical-reader-backend
tar -czf backup-$(date +%Y%m%d).tar.gz data/

# Yerel bilgisayara indir
scp -i your-key.pem ubuntu@YOUR_EC2_IP:~/optical-reader-backend/backup-*.tar.gz .
```

---

## İletişim ve Destek

Sorun yaşarsanız:
1. Docker loglarını kontrol edin
2. EC2 instance loglarını kontrol edin
3. Security Group ayarlarını kontrol edin

**Test URL:** `http://YOUR_EC2_IP:8080/health`
