#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

# Install Apache + PHP with extensions
sudo apt install -y apache2 php php-mysql php-curl php-gd php-mbstring php-xml php-zip php-intl libapache2-mod-php php-cli php-common php-mysqli

# Start and enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Download WordPress
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz

# Move WordPress to web root
sudo rm -rf /var/www/html/*
sudo mv wordpress/* /var/www/html

# Set permissions
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

# Restart Apache to apply changes
sudo systemctl restart apache2
