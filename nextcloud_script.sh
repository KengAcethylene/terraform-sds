#!/bin/bash

#install dependency
apt update -y
apt upgrade -y
apt install -y apache2 libapache2-mod-php7.4
apt install -y php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring php7.4-intl
apt install -y php7.4-gmp php7.4-bcmath php-imagick php7.4-xml php7.4-zip
apt install -y unzip

#install nextcloud
wget https://download.nextcloud.com/server/releases/nextcloud-22.2.0.zip
unzip nextcloud-22.2.0.zip
cp -r nextcloud /var/www

#apache config
echo "Alias /nextcloud "/var/www/nextcloud/"

<Directory /var/www/nextcloud/>
  Satisfy Any
  Require all granted
  AllowOverride All
  Options FollowSymLinks MultiViews

  <IfModule mod_dav.c>
    Dav off
  </IfModule>
</Directory>" > /etc/apache2/sites-available/nextcloud.conf

a2ensite nextcloud.conf
a2enmod rewrite
a2enmod ssl
a2ensite default-ssl

service apache2 restart

#nextcloud config
cd /var/www/nextcloud

echo "<?php
\$CONFIG = array (
  'objectstore' => array(
        'class' => '\\OC\\Files\\ObjectStore\\S3',
        'arguments' => array(
                'bucket' => '${BUCKET_NAME}',
                'key'    => '${ACCESS_ID}',
                'secret' => '${ACCESS_SECRET}',
                'port' => 443,
                'use_ssl' => true,
                'region' => '${REGION}',
                'use_path_style'=>true,
        ),
  ),
);" > ./config/config.php

php occ maintenance:install --database "mysql" --database-name "${DB_DATABASE}"  --database-user "${DB_USER}" --database-pass "${DB_PASSWORD}" --admin-user "admin" --admin-pass "${ADMIN_PASSWORD}" --database-host "${DATABASE_PRIVATE_IP}"

php occ config:system:set trusted_domains 1 --value=${PUBLIC_IP}

chown -R www-data:www-data /var/www/nextcloud

