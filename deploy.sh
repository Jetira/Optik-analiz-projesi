sudo yum install -y unzip
mkdir -p ~/optical-reader-backend
unzip -o ~/backend-deploy.zip -d ~/optical-reader-backend
cd ~/optical-reader-backend
sudo docker rm -f optical-backend || true
sudo docker build -t optical-backend .
sudo docker run -d -p 8080:8080 --name optical-backend --restart unless-stopped optical-backend
