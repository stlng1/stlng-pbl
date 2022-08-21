#!/bin/bash

sudo yum install nfs-utils nfs4-acl-tools -y

sudo mkdir /var/www

sudo mount -t nfs -o rw,nosuid 172.31.42.235:/mnt/apps /var/www

sudo echo "172.31.42.235:/mnt/apps /var/www nfs defaults 0 0" >> /etc/fstab

sudo yum install httpd -y

sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y

sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

sudo dnf module reset php -y

sudo dnf module enable php:remi-7.4 -y

sudo dnf install php php-opcache php-gd php-curl php-mysqlnd -y

sudo systemctl start php-fpm

sudo systemctl enable php-fpm

sudo setsebool -P httpd_execmem 1

sudo mkdir -p /home/recovery/logs

sudo rsync -av /var/log/. /home/recovery/logs/

sudo mount -t nfs -o rw,nosuid 172.31.42.235:/mnt/logs /var/log

sudo rsync -av /home/recovery/logs/. /var/log

sudo echo "172.31.42.235:/mnt/logs /var/log nfs defaults 0 0" >> /etc/fstab



