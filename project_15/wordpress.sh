#!/usr/bin/bash
##install httpd webserver
sudo su
sudo yum update -y
sudo yum install mysql -y
sudo yum install httpd -y
sudo systemctl enable httpd
##configure httpd
cat > /etc/httpd/conf.d/vhosts.conf <<EOL
<VirtualHost *:80>
    DocumentRoot /var/www/html/wordpress/
    ServerName wordpress.orieja.com.ng
    ErrorLog logs/wordpress.orieja.com.ng-error_log
    CustomLog logs/wordpress.orieja.com.ng-access_log common
</VirtualHost>
EOL
sudo systemctl start httpd
sudo chkconfig httpd on
##mount efs on server
cd /var/www
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport < efs-ip >:/ html



##install wordpress
cd html
sudo wget http://wordpress.org/latest.tar.gz
sudo tar xzvf latest.tar.gz
sudo rm -rf latest.tar.gz
sudo cp wordpress/wp-config-sample.php wordpress/wp-config.php
sudo chown -R ec2-user:ec2-user /var/www/html/wordpress
sudo setsebool -P httpd_can_network_connect=1
##set database details with perl find and replace
sed -i 's/database_name_here/wordpress/g;s/username_here/admin/g;s/password_here/PassWord/g;s/localhost/< rds-end-point-here >/g' /var/www/html/wordpress/wp-config.php