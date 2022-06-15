# **WEB STACK IMPLEMENTATION (LAMP STACK) IN AWS**

## **AWS account setup and Provisioning and Ubuntu Server**
1. register AWS account
2. create Darey_Projects_01 instance of ubuntu server

![ubuntu ec2 instance](https://github.com/stlng1/stlng-pbl/blob/main/aws_ec2_instance.jpg)

## **Connecting to EC2 terminal**

Connect to EC2 terminal using the git bash from folder containing my private key

>**ssh -i femmy_ec2.pem ubuntu@13.38.85.104:80**
  
![connect to ec2 instance](https://github.com/stlng1/stlng-pbl/blob/main/ec2_connect.png)

## **Installing Apache**

Update a list of packages in package manager
  
>**sudo apt update**

Run apache2 package installation

>**sudo apt install apache2**

Verify that apache2 is running as a Service in our OS

>**sudo systemctl status apache2**

Add a rule to EC2 configuration to open inbound connection through port 80

![New inbound connection through port 80 rule](https://github.com/stlng1/stlng-pbl/blob/main/ec2_apache.png)

Check Apache access locally in our Ubuntu shell

>**curl http://127.0.0.1:80**

Test how our Apache HTTP server respond to requests from the Internet browser

>**http://13.38.85.104:80**

![Apache server works!](https://github.com/stlng1/stlng-pbl/blob/main/ec2_apache2.png)

## **Install MySQL**

Acquire and install MySQL server app

> **sudo apt install mysql-server**

Log in to the MySQL console

> **sudo mysql**

![MyQL works!](https://github.com/stlng1/stlng-pbl/blob/main/ec2_mysql_1.png)

Set a password for the root user, using mysql_native_password as default authentication method

> **ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'PassWord.1';**

Exit the MySQL shell

> **exit**

Run a security script to remove some insecure default settings and lock down access to your database system.

> **sudo mysql_secure_installation**

Test if you’re able to log in to the MySQL console

![MyQL still works!](https://github.com/stlng1/stlng-pbl/blob/main/ec2_mysql_2.png)

Exit the MySQL console

> **exit**

## **Installing PHP**

To install the following at once - php package, php-mysql, a PHP module that allows PHP to communicate with MySQL-based databases and libapache2-mod-php to enable Apache to handle PHP files

> **sudo apt install php libapache2-mod-php php-mysql**

To confirm PHP version

> **php -v**

![PHP version 8.1.2](https://github.com/stlng1/stlng-pbl/blob/main/ec2_php_1.png)

LAMP stack is completely installed and fully operational

# **CREATING A VIRTUAL HOST FOR YOUR WEBSITE USING APACHE**

In this project, you will set up a domain called projectlamp

Create the directory for projectlamp

> **sudo mkdir /var/www/projectlamp**

Assign ownership of the directory to current system user

> **sudo chown -R $USER:$USER /var/www/projectlamp**

Create and open a new configuration file in Apache’s sites-available directory

> **sudo vi /etc/apache2/sites-available/projectlamp.conf**

This will create a new blank file. Paste in the following bare-bones configuration by hitting on i on the keyboard to enter the insert mode, and paste the text:
```
 <VirtualHost *:80>
 
    ServerName projectlamp
    
    ServerAlias www.projectlamp 
    
    ServerAdmin webmaster@localhost
    
    DocumentRoot /var/www/projectlamp
    
    ErrorLog ${APACHE_LOG_DIR}/error.log
    
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    
 </VirtualHost>
```
To save and close the file, simply follow the steps below:

> 1. Hit the **esc** button on the keyboard
> 2. Type :
> 3. Type **wq. w** for write and **q** for quit
> 4. Hit **ENTER** to save the file

Confirm the new file is created in the sites-available directory by list command

> **sudo ls /etc/apache2/sites-available**

With this VirtualHost configuration, we’re telling Apache to serve projectlamp using /var/www/projectlamp as its web root directory
Use a2ensite command to enable the new virtual host

> **sudo a2ensite projectlamp**

To disable Apache’s default website use a2dissite command

> **sudo a2dissite 000-default**

To make sure your configuration file doesn’t contain syntax errors, run:

> **sudo apache2ctl configtest**

Finally, reload Apache so these changes take effect:

> **sudo systemctl reload apache2**

Your new website is now active, but the web root /var/www/projectlamp is still empty. Create an index.html file in that location so that we can test that the virtual host works as expected:
sudo echo 'Hello LAMP from hostname' $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) 'with public IP' $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) > /var/www/projectlamp/index.html

Go to your browser and try to open your website URL using IP address:

> **http://52.47.159.82:80**
  
![Apache virtual host is working as expected](https://github.com/stlng1/stlng-pbl/blob/main/ec2_lamp_1.png)

## **ENABLE PHP ON THE WEBSITE**
  
Create a PHP script to test that PHP is correctly installed and configured on your server

Create a new file named index.php inside your custom web root folder

> **vim /var/www/projectlamp/index.php**

Add the following lines of text, which is valid PHP code, inside the file:

```
<?php

 phpinfo();
```

With the default DirectoryIndex settings on Apache, a file named index.html will always take precedence over an index.php file. rename index.html to index.xtml so that index.php is default file.

> **mv /var/www/projectlamp/index.html  /var/www/projectlamp/index.xtml**

Go to your browser and try to open your website URL using IP address:

> **http://52.47.159.82:80**

![PHP installation is working as expected](https://github.com/stlng1/stlng-pbl/blob/main/ec2_php_2.png)

After checking the relevant information about your PHP server through that page, it’s best to remove the file you created as it contains sensitive information about your PHP environment -and your Ubuntu server

> **sudo rm /var/www/projectlamp/index.php**
