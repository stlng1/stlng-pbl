#!/usr/bin/bash
sudo yum update -y
sudo yum install python3 -y
sudo dnf install chrony
sudo yum -y install net-tools
sudo yum install vim-enhanced -y
sudo yum install wget -y
sudo yum install telnet -y 
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
sudo yum install htop -y
sudo dnf install nfs-utils nfs4-acl-tools -y