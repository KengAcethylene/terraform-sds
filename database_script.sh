#!/bin/bash
apt update -y
apt upgrade -y
apt install -y mariadb-server

echo "[mysqld]
skip-networking=0
skip-bind-address" >> /etc/mysql/mariadb.conf.d/50-server.cnf

systemctl restart mariadb

echo "CREATE USER '${database_user}'@'192.168.2.100' IDENTIFIED BY '${database_pass}';
CREATE DATABASE IF NOT EXISTS ${database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON ${database_name}.* TO '${database_user}'@'192.168.2.100';
FLUSH PRIVILEGES;" > /home/ubuntu/init.sql

mysql < /home/ubuntu/init.sql