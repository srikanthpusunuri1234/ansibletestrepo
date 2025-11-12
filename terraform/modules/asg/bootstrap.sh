#!/bin/bash
# Update system and install required packages: Nginx, Docker (from Ubuntu repo), and Java 17

# --- Update and upgrade ---
sudo apt update -y
sudo apt upgrade -y

# --- Install Nginx ---
sudo apt install -y nginx
sudo systemctl start nginx

cd /var/www/html
sudo git clone https://github.com/Ironhack-Archive/online-clone-amazon.git
sudo mv online-clone-amazon/* .

sudo systemctl reload nginx

# awscli installation
#cd /tmp
#sudo apt install unzip
#sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip -q awscliv2.zip && sudo ./aws/install && aws --version
#sudo aws s3 cp s3://sergsergjnsjhuighushe/index.html /var/www/uat/

echo -e '#!/bin/bash
echo Hello from cron > /tmp/cron-test.log' > /root/myscript.sh

CRON_JOB="*/1 * * * * /root/myscript.sh"

(crontab -l 2>/dev/null || echo "") | crontab - <<< "$CRON_JOB"

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

