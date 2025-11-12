#!/bin/bash
# Update system and install required packages: Nginx, Docker (from Ubuntu repo), and Java 17

# --- Update and upgrade ---
sudo apt update -y
sudo apt upgrade -y

# --- Install Nginx ---
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

cd /var/www/html
sudo git clone https://github.com/CleverProgrammers/pwj-netflix-clone.git
sudo mv pwj-netflix-clone/* .

sudo systemctl reload nginx


# --- Install Docker (from Ubuntu repo) ---
#sudo apt install -y docker.io
#sudo systemctl enable --now docker
#sudo usermod -aG docker ubuntu   # allow 'ubuntu' user to run docker without sudo

# --- Install Java 17 ---
#sudo apt install -y openjdk-17-jdk

# Verify installations
#echo "--- Verifying Installations ---" >> /var/log/user_data.log
#java -version >> /var/log/user_data.log
#nginx -v >> /var/log/user_data.log
#docker -v >> /var/log/user_data.log
#echo "-------------------------------" >> /var/log/user_data.log