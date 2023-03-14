#!/usr/bin/bash
##install httpd webserver
sudo su
sudo yum update -y
sudo yum install mysql -y
sudo yum install httpd -y
sudo systemctl enable httpd
##configure httpd
#sudo sed -i -e 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
cat > /etc/httpd/conf.d/vhosts.conf <<EOL
<VirtualHost *:80>
    DocumentRoot /var/www/html/tooling/
    ServerName tooling.orieja.com.ng
    ErrorLog logs/tooling.orieja.com.ng-error_log
    CustomLog logs/tooling.orieja.com.ng-access_log common
</VirtualHost>
EOL
##Configure SELinux allow http to listen on TCP ports 8081
# sudo yum -y install policycoreutils-python-utils
# sudo semanage port -m -t http_port_t -p tcp 8081
##Starting httpd Services
sudo systemctl start httpd
sudo chkconfig httpd on
##mount efs on server
cd /var/www
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport <efs-ip>:/ html


##install tooling
cd html
sudo git clone https://github.com/stlng1/tooling.git
sudo mv tooling/html/* tooling/.
sudo chown -R ec2-user:ec2-user /var/www/html/tooling
sudo setsebool -P httpd_can_network_connect 1

##connect database to webserver configuration details with perl find and replace
sed -i "s/'mysql.tooling.svc.cluster.local', 'admin', 'admin', 'tooling/'< rds-end-point-here >', 'admin', 'PassWord', 'tooling/g" /var/www/html/tooling/functions.php

