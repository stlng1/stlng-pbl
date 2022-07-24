# shell scripting
# This script will read a csv file that contains 20 new linux users
# This script will create each user on the server an add them to a exisiting group called 'developers'
# This script will first check for the existece of the user on the system before it will attemptto create it
# The user being created must also have a default home folder
# Each user must have a .SSH folder within it's HOME folder. If it does not exist, t will be created.
# For each users SSH configuration, it will create an authorized_keys file and add the below public key

#!/bin/bash
userfile=$(cat names.csv)
PASSWORD=password

# To ensure that the user running this script has sudo priviledge (i.e id=0)
    if [ $(id -u) -eq 0 ]; then

# Reading the csv file
        for user in $userfile;
        do  
            echo $user
        if id "$user" &>/dev/null
        then
            echo "User Exist"
        else

# This will create a new user
        useradd -m -d /home/$user -s /bin/bash -g developers $user
        echo "New User Created"        
        echo

# This will create a .ssh folder in the user home folder
        su - -c "mkdir ~/.ssh" $user
        echo ".ssh directory created for new user"
        echo

# we need to set the user permission for the ssh directory
        su - -c "chmod 700 ~/.ssh" $user
        echo "user permission for .ssh directory set"
        echo

# This will create an authorized-key file
        su - -c "touch ~/.ssh/authorized-keys" $user
        echo "Authorized-Key file Created"
        echo

# We need to set permission for the key file
        su - -c "chmod 600 ~/.ssh/authorized-keys" $user
        echo "user permission for the authorized key file set"
        echo

# We need to create and set public key for the users in the server
        cp -R "/home/ubuntu/.ssh/id_rsa.pub" "/home/$user/.ssh/authorized_keys"       
        echo "copied the public key to new user account on the server"
        echo
        echo

        echo "USER CREATED"

# Generate a password
sudo echo -e "$PASSWORD\n$PASSWORD" | sudo passwd "$user" 
sudo passwd -x 5 $user
            fi
        done
    else
    echo "Only Admin CAN Onboard A User"
    fi
