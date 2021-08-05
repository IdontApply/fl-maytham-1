#!/usr/bin/bash
set -x
sudo apt update -y
sudo apt -y upgrade
sudo apt install nginx -y
sudo ufw allow 'Nginx HTTP'

sudo mkdir -p /var/www/domain/html
sudo chown -R $USER:$USER /var/www/domain/html
sudo chmod -R 755 /var/www/domain


sudo python3 /tmp/nginx.py $1

yes | sudo cp /tmp/index.html /var/www/domain/html
yes | sudo cp /tmp/index.html /var/www/html/index.nginx-debian.html
yes | sudo cp /tmp/domain /etc/nginx/sites-available

sudo ln -s /etc/nginx/sites-available/domain /etc/nginx/sites-enabled/
sudo systemctl restart nginx
set +x
