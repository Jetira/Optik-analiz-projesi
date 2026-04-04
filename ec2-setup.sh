#!/bin/bash
# EC2 Backend Kurulum Scripti
# Ubuntu 22.04 için

set -e

echo "🚀 Optical Reader Backend Kurulumu Başlıyor..."

# 1. Sistem güncellemesi
echo "📦 Sistem güncelleniyor..."
sudo apt update
sudo apt upgrade -y

# 2. Docker kurulumu
echo "🐳 Docker kuruluyor..."
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# 3. Backend dizini oluştur
echo "📁 Backend dizini hazırlanıyor..."
mkdir -p ~/optical-reader-backend
cd ~/optical-reader-backend

# 4. Unzip backend dosyalarını (manuel olarak yüklenecek)
echo "📂 Backend dosyaları bekleniyor..."
echo "   Lütfen backend-deploy.zip dosyasını bu dizine yükleyin"
echo "   Komut: scp -i your-key.pem backend-deploy.zip ubuntu@YOUR_EC2_IP:~/optical-reader-backend/"

# 5. Docker image oluştur ve çalıştır (zip açıldıktan sonra)
# sudo docker build -t optical-backend .
# sudo docker run -d -p 8080:8080 --name optical-backend --restart unless-stopped optical-backend

echo "✅ Kurulum scripti hazır!"
echo ""
echo "📝 Sonraki Adımlar:"
echo "1. backend-deploy.zip dosyasını EC2'ye yükleyin"
echo "2. unzip backend-deploy.zip"
echo "3. sudo docker build -t optical-backend ."
echo "4. sudo docker run -d -p 8080:8080 --name optical-backend --restart unless-stopped optical-backend"
echo "5. Test: curl http://localhost:8080/health"
