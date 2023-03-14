#!/usr/bin/bash
##Installing Nginx
sudo su
sudo yum update -y
sudo yum install nginx -y
##Modifying Nginx Server Configuration for reverse proxy
##create conf files for tooling and wordpress servers respectively
sudo cat > /etc/nginx/conf.d/wordpress.conf << 'EOL'
server {
    listen 80;
    server_name wordpress.orieja.com.ng;
    location / {
        proxy_pass http://internal-privateALB-147132026.eu-west-3.elb.amazonaws.com/;
        proxy_set_header Host $host;
        }
    }
EOL

sudo cat > /etc/nginx/conf.d/tooling.conf << 'EOL'
server {
    listen 80;
    server_name tooling.orieja.com.ng;
    location / {
        proxy_pass http://internal-privateALB-147132026.eu-west-3.elb.amazonaws.com/;
        proxy_set_header Host $host;
        }
    }
EOL
##Starting Nginx Services
sudo systemctl enable nginx
sudo systemctl start nginx
sudo chkconfig nginx on
sudo setsebool -P httpd_can_network_connect 1