#!/bin/bash
apt update -y
apt upgrade -y
apt install -y nginx
systemctl start nginx
systemctl enable nginx
chown -R ubuntu:ubuntu /var/www
chmod 2775 /var/www