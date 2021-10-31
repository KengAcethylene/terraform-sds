#!/bin/bash
apt update -y
apt upgrade -y
apt install -y mariadb-server

echo "[mysqld]
skip-networking=0
skip-bind-address" >> /etc/mysql/mariadb.conf.d/50-server.cnf

systemctl restart mariadb

echo "CREATE USER '${DB_USER}'@'${NEXTCLOUD_PRIVATE_IP}' IDENTIFIED BY '${DB_PASSWORD}';
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON nextcloud.* TO '${DB_USER}'@'${NEXTCLOUD_PRIVATE_IP}';
FLUSH PRIVILEGES;" > /home/ubuntu/init.sql

mysql < /home/ubuntu/init.sql