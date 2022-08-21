# Devops Tooling Website Solution

# Prepare and Configure NFS Server

Spin up a new EC2 instance with RHEL Linux 8 Operating System.

![EC2 instances in AWS](./images/p7_aws_1.png)

## Configure LVM on the Server.

Add EBS Volume to an EC2 instance here

![EBS volume in AWS](./images/p7_aws_2.png)

Attach all two volumes one by one to your Web Server EC2 instance

Open up the Linux terminal to begin configuration

Use *lsblk* command to inspect what block devices are attached to the server. 

```lsblk```

Notice names of your newly created devices. 

All devices in Linux reside in /dev/ directory. Inspect it with ls /dev/ and make sure you see all 3 newly created block devices there – their names will likely be xvdf, xvdh, xvdg.

```ls /dev/```

Use df -h command to see all mounts and free space on your server

```df -h```

![checking attached volumes](./images/p7_LVM_1.png)


Use gdisk utility to create a single partition on each of the 2 disks

```sudo gdisk /dev/xvdf```

![creating partitions](./images/p7_LVM_2.png)


Now, your changes has been configured succesfully, do the same for the remaining disks.

```sudo gdisk /dev/xvdg```

Use *lsblk* utility to view the newly configured partition on each of the 2 disks.

![checking attached volumes](./images/p7_LVM_3.png)


Install lvm2 package 

```sudo yum install lvm2```

*Note: Previously, in Ubuntu we used 'apt' command to install packages, in RedHat/CentOS a different package manager is used, so we shall use 'yum' command instead.*

check for available partitions, run: 

```sudo lvmdiskscan```

![checking partitions](./images/p7_LVM_4.png)


Use *pvcreate* utility to mark each of 2 disks as physical volumes (PVs) to be used by LVM

```sudo pvcreate /dev/xvdf1```

```sudo pvcreate /dev/xvdg1```

Verify that your Physical volume has been created successfully, run: 

```sudo pvs```

![verify physical volume](./images/p7_LVM_5.png)

Use vgcreate utility to add all 2 PVs to a volume group (VG). Name the VG webdata-vg

```sudo vgcreate nfs-vg /dev/xvdg1 /dev/xvdf1```

Verify that your VG has been created successfully, run:

```sudo vgs```

![create volume group](./images/p7_LVM_6.png)

Use lvcreate utility to create 3 logical volumes. lv-opt (5Gb), lv-apps (5Gb), and lv-logs (use up the remaining space of the PV size). 

*NOTE: lv-apps – to be used by webservers; lv-logs to be used by webserver logs; and lv-opt – to be used by Jenkins server in Project 8*

```sudo lvcreate -n lv-apps -L 5G nfs-vg```

```sudo lvcreate -n lv-logs -L 5G nfs-vg```

```sudo lvcreate -n lv-opt -L 5G nfs-vg```

Verify that your Logical Volume has been created successfully. Run:

```sudo lvs```

![verify logical volume](./images/p7_LVM_7.png)

Verify the entire setup

```sudo vgdisplay -v #view complete setup - VG, PV, and LV```

```sudo lsblk```

![verify logical volume](./images/p7_LVM_8.png)

Use mkfs.xfs to format the logical volumes with xfs filesystem

```sudo mkfs -t xfs /dev/nfs-vg/lv-apps```

```sudo mkfs -t xfs /dev/nfs-vg/lv-logs```

```sudo mkfs -t xfs /dev/nfs-vg/lv-opt```

Create **/mnt/apps** directory to store website files

```sudo mkdir -p /mnt/apps```

Create **/mnt/logs** to store backup of log data

```sudo mkdir -p /mnt/logs```

Create **/mnt/opt** to store Jenkins files

```sudo mkdir -p /mnt/opt```

Mount **/mnt/apps** on **lv-apps** logical volume

```sudo mount /dev/nfs-vg/lv-apps /mnt/apps```

Mount **/mnt/logs** on **lv-logs** logical volume

```sudo mount /dev/nfs-vg/lv-logs /mnt/logs```

Mount **/mnt/opt** on **lv-opt** logical volume

```sudo mount /dev/nfs-vg/lv-opt /mnt/opt```

## UPDATE THE `/ETC/FSTAB` FILE

Update */etc/fstab* file so that the mount configuration will persist after restart of the server.

The UUID of the device will be used to update the /etc/fstab file;

To extract the UUID of the device, run:

```sudo blkid```

![device UUID](./images/p7_LVM_9.png)

To replace the UUID of the /etc/fstab file, run:

```sudo vi /etc/fstab```

![replace fstab file UUID](./images/p7_LVM_10.png)

Update */etc/fstab* in the format shown above using your own UUID and remember to remove the leading and ending quotes.

Test the configuration and reload the daemon

```sudo mount -a```

```sudo systemctl daemon-reload```

Verify your setup. Run: 

```df -h```

output must look like this:

![new configuration](./images/p7_LVM_11.png)

## Install NFS Server

configure it to start on reboot and make sure it is up and running.

```
sudo yum -y update
sudo yum install nfs-utils -y
sudo systemctl start nfs-server.service
sudo systemctl enable nfs-server.service
sudo systemctl status nfs-server.service
```

Export the mounts for webservers’ subnet CIDR to connect as clients. There will be three Web Servers installed in the same subnet.

To check your subnet CIDR – click on your EC2 instance to open the Subnet ID link:

![subnet CIDR in AWS](./images/p7_aws_4.png)

Make sure we set up permission that will allow our Web servers to read, write and execute files on NFS:

```
sudo chown -R nobody: /mnt/apps
sudo chown -R nobody: /mnt/logs
sudo chown -R nobody: /mnt/opt

sudo chmod -R 777 /mnt/apps
sudo chmod -R 777 /mnt/logs
sudo chmod -R 777 /mnt/opt
```

restart NFS Server

```sudo systemctl restart nfs-server.service```

Configure access to NFS for clients within the same subnet by editing *exports* file (example of Subnet CIDR – 172.31.0.0/16):

```sudo vi /etc/exports```

```
*insert into the exports file*

/mnt/apps <Subnet-CIDR>(rw,sync,no_all_squash,no_root_squash)
/mnt/logs <Subnet-CIDR>(rw,sync,no_all_squash,no_root_squash)
/mnt/opt <Subnet-CIDR>(rw,sync,no_all_squash,no_root_squash)
```

![exports file configuration](./images/p7_LVM_12.png)

test exports file 

```sudo exportfs -arv```

Check which port is used by NFS and open it using Security Groups (add new Inbound Rule)

```rpcinfo -p | grep nfs```

![check ports](./images/p7_LVM_13.png)

Important note: In order for NFS server to be accessible from your client, you must also open following ports: TCP 111, UDP 111, UDP 2049

create a new security group in your EC2 instance to allow in-bound traffic in the listed ports.

![EC2 security group](./images/p7_AWS_3a.png)

# Prepare and Configure Database Server

## Prepare Database Server

Spin up a new EC2 instance with Linux Ubuntu 22.04 Operating System.

![EC2 instances in AWS](./images/p7_aws_5.png)

## Install MySQL server

```sudo apt update```

```sudo apt install mysql-server```

Verify that the service is up and running 

```sudo systemctl status mysql```

## Configure MySQL Installation

Log in to the MySQL console

```sudo mysql```

It’s recommended that you run a security script that comes pre-installed with MySQL. This script will remove some insecure default settings and lock down access to your database system. Before running the script you will set a password for the root user, using mysql_native_password as default authentication method. We’re defining this user’s password as PassWord.1.

```ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'PassWord.1';```

Exit the MySQL shell

```exit```

Run a security script to remove some insecure default settings and lock down access to your database system.

```sudo mysql_secure_installation```

login mysql

```sudo mysql -p```

Create a database and name it *tooling*

```CREATE DATABASE tooling;```

Create a database user and name it *webaccess*

```CREATE USER 'webaccess'@'%' IDENTIFIED BY 'weba';```

Grant permission to *webaccess* user on *tooling* database to do anything only from the webservers Subnet CIDR

```GRANT ALL PRIVILEGES ON tooling.* TO 'webaccess'@'%';```

```FLUSH PRIVILEGES;```

```SHOW DATABASES;```

```exit```

![check ports](./images/p7_LVM_14.png)


# Prepare and Configure Webservers

We need to make sure that our Web Servers can serve the same content from shared storage solutions, in our case – NFS Server and MySQL database.

You already know that one DB can be accessed for reads and writes by multiple clients. For storing shared files that our Web Servers will use – we will utilize NFS and mount previously created Logical Volume *lv-apps* to the folder where Apache stores files to be served to the users (/var/www).

This approach will make our Web Servers *stateless*, which means we will be able to add new ones or remove them whenever we need, and the integrity of the data (in the database and on NFS) will be preserved.

## Launch Webservers and Configure as NFS client 

(this step must be done on all three webservers)

1. Launch new EC2 instances with RHEL 8 Operating System

![AWS RHEL Instance](./images/p7_AWS_6.png)

2. Install NFS client

```sudo yum install nfs-utils nfs4-acl-tools -y```

3. Mount /var/www/ and target the NFS server’s export for apps

```sudo mkdir /var/www```

```sudo mount -t nfs -o rw,nosuid <NFS-Server-Private-IP-Address>:/mnt/apps /var/www```

4. Verify that NFS was mounted successfully by running 

```df -h```

![NFS mount verification](./images/p7_LVM_15.png)

5. To make sure that the changes will persist on Web Server after reboot, edit fstab file:

```sudo vi /etc/fstab```

add following line

```<NFS-Server-Private-IP-Address>:/mnt/apps /var/www nfs defaults 0 0```

![edit fstab file](./images/p7_LVM_16.png)

6. Install Remi’s repository, Apache and PHP

```
sudo yum install httpd -y

sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm

sudo dnf module reset php

sudo dnf module enable php:remi-7.4

sudo dnf install php php-opcache php-gd php-curl php-mysqlnd

sudo systemctl start php-fpm

sudo systemctl enable php-fpm

sudo setsebool -P httpd_execmem 1
```

Verify that Apache files and directories are available on the Web Server in /var/www 

![verify NFS mount](./images/p7_LVM_18.png)

and also on the NFS server in /mnt/apps. 

![verify NFS mount](./images/p7_LVM_17.png)

If you see the same files as in the images above, it means NFS is mounted correctly. 

Next, locate the log folder for Apache on the Web Server, */var/log/* and mount it to NFS server’s export for logs, */mnt/logs/*; this process will delete all files in the log directory, so it is necessary to backup before proceeding.

>Create */home/recovery/logs* to store backup of log data
>
>```sudo mkdir -p /home/recovery/logs```
>
>Use *rsync* utility to backup all the files in the log directory into */home/recovery/logs* 
>
>```sudo rsync -av /var/log/. /home/recovery/logs/```

7. ount */var/log/* to NFS server’s */mnt/logs/*
(Note that all the existing data on /var/log will be deleted. That is why the backup step above is very important)

```sudo mount -t nfs -o rw,nosuid <NFS-Server-Private-IP-Address>:/mnt/logs /var/log```

>Restore log files back into */var/log* directory
>
>```sudo rsync -av /home/recovery/logs/. /var/log```

8. Update */etc/fstab* file so that the mount configuration will persist after restart of the server.

```sudo vi /etc/fstab```

add following line

```<NFS-Server-Private-IP-Address>:/mnt/logs /var/log nfs defaults 0 0```

to make sure the mount point will persist after reboot.

9. Repeat all the steps above for another 2 Web Servers except the backup & restore. (you can also write a shell script to automate the installation for the other 2 servers like we did. see webshell.sh)

# Deploy a Tooling application to our Web Servers into a shared NFS folder

Fork the tooling source code from Darey.io Github Account to your Github account. 

![fork tooling source code](./images/p7_img_1.png)

Deploy the tooling website’s code to the Webserver as *root* user. Ensure that the html folder from the repository is deployed to /var/www/html. Note that this does not have to be repeated on other servers since the directory is shared.

```cd /var/www/html```

```sudo git clone <git-repository-url>```

![git repo url](./images/p7_img_2.png)
```

Notes
1. Install git if it is not been installed on your server.

sudo yum install git

2. Do not forget to open TCP port 80 on the Web Server. You can do this by modifying your EC2 security group.

3. If you encounter 403 Error – check permissions to your /var/www/html folder and also disable SELinux:

sudo setenforce 0

To make this change permanent – open following config file 

sudo vi /etc/sysconfig/selinux

and set **SELINUX=disabled** then restart httpd.
```

move all files in tooling directory to /var/www/html

```mv /var/www/html/tooling/* /var/www/html```

delete tooling directory

```rm -r /var/www/html/tooling```

next move all files in html directory to /var/www/html

```mv /var/www/html/html/* /var/www/html```

then, delete html directory

```rm -r /var/www/html/html```

# Configure the Web Servers to work with a single MySQL 

Open MySQL port 3306 to inbound traffic on DB Server EC2. For extra security, you should allow access to the DB server ONLY from your Web Server’s security group as shown in the image below.

![new security configuration](./images/p7_aws_7.png)

configure database server to allow connections from remote hosts.

```sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf```

Replace ‘127.0.0.1’ to ‘0.0.0.0’ like this:

![edit mysqld.cnf](./images/p7_LVM_19.png)

restart server

```sudo systemctl restart mysql```

## Test that you can connect from your Web Server to your Database server.

verify that the service is up and running 

```sudo systemctl status httpd```

if it is not running, restart the service and enable it so it will be running even after reboot:

```sudo systemctl enable httpd```

```sudo systemctl restart httpd```

login to mysql client as admin or root user with the command line below. (ensure no space between the -p and password. see image below)

```sudo mysql -u <admin user> -p -h <DB-Server-Private-IP-address>```

if you encounter permission or access denied errors, run command below and try login again.

```sudo setenforce 0```

Verify if you can successfully executed the command 

```SHOW DATABASES;```

See a list of existing databases.

![databases](./images/p7_LVM_20.png)

## Update the website’s configuration

Update the website’s configuration to connect to the database; edit /var/www/html/functions.php file.

```vi /var/www/html/functions.php```

![edit functions.php](./images/p7_LVM_21.png)

Apply tooling-db.sql script to your database 

go to /var/www/html/

```cd /var/www/html/```

```sudo mysql -u <db-username> -p<db-pasword> -h <databse-private-ip> tooling < tooling-db.sql```

Netx, login to mysql

```sudo mysql -u <db-username> -p<db-pasword> -h <databse-private-ip> tooling```

```SHOW DATABASES;```

```select * from users```

![databases & users](./images/p7_img_4.png)

Open the website in your browser 

```http://<Web-Server-Public-IP-Address-or-Public-DNS-Name>/index.php```

and make sure you can login into the website with 'admin' user and 'admin' password.

Web browser 1

![browser 1](./images/p7_img_5.png)

Web browser 2

![browser 2](./images/p7_img_6.png)

Web browser 3

![browser 3](./images/p7_img_7.png)

