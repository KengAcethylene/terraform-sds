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


echo "<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/nextcloud

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog  /var/log/error.log
        CustomLog /var/log/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet" > /etc/apache2/sites-available/000-default.conf

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

php occ maintenance:install --database "mysql" --database-name "${database_name}"  --database-user "${database_user}" --database-pass "${database_pass}" --admin-user "${admin_user}" --admin-pass "${admin_pass}" --database-host "192.168.2.101"

php occ config:system:set trusted_domains 1 --value=${PUBLIC_IP}

chown -R www-data:www-data /var/www/nextcloud

