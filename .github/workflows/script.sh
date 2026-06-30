#!/bin/bash

set -e

REPO_URL="https://github.com/ufuomaorieruo/static-vm-cicd.git"
APP_DIR="/var/www/static-vm-cicd"
SITE_NAME="static-vm-cicd"

echo "Updating server..."
sudo apt update -y

echo "Installing required packages..."
sudo apt install nginx git -y

echo "Cloning website repository..."
sudo rm -rf "$APP_DIR"
sudo git clone "$REPO_URL" "$APP_DIR"

echo "Setting permissions..."
sudo chown -R azureuser:azureuser "$APP_DIR"
sudo chmod -R 755 "$APP_DIR"

echo "Creating Nginx configuration..."
sudo tee /etc/nginx/sites-available/$SITE_NAME > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    root $APP_DIR;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

echo "Enabling website..."
sudo ln -sf /etc/nginx/sites-available/$SITE_NAME /etc/nginx/sites-enabled/$SITE_NAME
sudo rm -f /etc/nginx/sites-enabled/default

echo "Testing Nginx..."
sudo nginx -t

echo "Restarting Nginx..."
sudo systemctl restart nginx
sudo systemctl enable nginx

echo "Initial VM setup completed."