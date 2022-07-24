# AUX PROJECT 1: SHELL SCRIPTING

In this project, we need to onboard 20 new Linux users onto a server. Create a shell script that reads a csv file that contains the first name of the users to be onboarded.

## Create a New EC2 Ubuntu Instance on AWS

Create and configure a new Ubuntu Instance on AWS named AUX-Project-01

![EC2 instance in AWS](./images/ec2_aws_1.png)

## Create Folders and Files

Create and go to the project folder called Shell

```mkdir  && cd shell```

Create *names.csv* file

```touch names.csv```

Open the names.csv file

```vim names.csv```

Insert some 20 random names below into it. (One name per line)

```
Femi
Banny
John
Mark
David
Ore
Banke
Toyin
Ngozi
Emeka
Ronke
Dupe
Daniel
Raymond
Kate
Ahmed
yusuf
Shelly
Okon
Efe
```
Create developers user group

```sudo groupadd developers```

confirm group has been created

```getent group developers```

![user group created](./images/ec2_script_1.png)

## Creating Onboarding Users Script 

1. The script you created should read the CSV file, create each user on the server, and add to an existing group called developers (You will need to manually create this group ahead).

2. Ensure that your script will first check for the existence of the user on the system, before it will attempt to create that it.

3. Ensure that the user that is being created also has a default home folder

4. Ensure that each user has a .ssh folder within its HOME folder. If it does not exist, then create it.

5. For each user’s SSH configuration, create an authorized_keys file and add ensxure it has the public key of your current user.

below is the script created to meet all the equirements listed above

```
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
```

## Create your script file named onboarding.sh

In the *shell* folder, create a new file named onboarding.sh

```touch onboarding.sh```

copy and paste your script (above) into onboarding.sh

```vi onboarding.sh```

make your script file executable by the following command

```chmod +x onboarding.sh```

## Creating Public and Private keys

Before Deploying your script, you will need to update your current user with the correct public key and private key.

In your current home directory change directory to .ssh folder

```cd .ssh```

create a file for the public key

```touch id_rsa.pub```

open the file using your favorite editor and paste in the public key

```vi id_rsa.pub```

```
The Public Key

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzKZyicHxIkklSrNlxsJyyTrcIdBIt84Z0cQb3R4k0jH53kxkaT5hP8tfWTe62LXi7vV86fY+SX7TBNM76XGCbw/6vrMGegm6J1x2i1AiLNwq5nqTjOGn0AIwku4IlCCLAB7tdfRyVuCarmBlwny3lzRyybIUAWXR/D6vpN09MsDILbKdhay+Q/p9OUBMSLPqXdY/QIh/Oe3rVv1lwY3AohNfq7V3tO88zKswfA5iiexNiSYX1myT0OrX8cBE771j9quoNZhQgaLI1mIMtAvnHQChrn9k2nUaO/BMBCQGol5XzGv1ado7hgoVPoluIUD+FGNo/pH4zcmDLICH6drXY/C9MESnkMUPLFxBXKO/OitApY71vRao9nAhAwpVMsy6FqiOb5uawhvhoHYIHTV/f4EtagVagRMP2PxYMYR6jykIV4MPJTkCm+lGhTyMlRu+qRQjdLn8AAtHf4aEV8dIkoGh088DI7eA/4o0wz4OV4upH5ewSFS+5IHmRECEW5Nc=
```

create a file for your private key

```touch id_rsa```

open the file using your favorite editor and paste in the private key.

```vi id_rsa```

```
The private key

-----BEGIN OPENSSH PRIVATE KEY-----
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
kmaSGj362OnCCNAAAACWRhcmVARGFyZQE=
-----END OPENSSH PRIVATE KEY-----
```

## Running your script

go back to your shell folder

```cd ~/shell```

switch to root user

```sudo su```

run your script

```./onboarding.sh```

![running onboarding script](./images/ec2_script_3.png)

## Verify the new users have been created succesfuly

```ls -la /home/```

![list of newly created users](./images/ec2_script_4.png)

Test a few of the users randomly, and ensure that you are able to connect to the server using the private key and the public key.

## Verify that the new user can use SSH to connect to the EC2 instance

copy private key (id_rsa) created earlier to your current working folder on your local system you wish to connect from as aux_01.pem. 

```scp -i "<Public Key>" ubuntu@ec2-35-180-14-171.eu-west-3.compute.amazonaws.com:/home/ubuntu/.ssh/id_rsa ./aux_01.pem```

general string:
> scp -i "<Public Key>" <user>@<EC2 public Ip>:<file to be copied> <destination file>

OR 

create a new private key on your local system following the same process above

secure the key by modifying the permissions

```chmod 600 aux_01.pem```

Run the following command from the command line prompt on your local computer:

```ssh -i <key_pair>.pem new_user@public_dns_name_of_EC2_Linux_instance```

![connection of newuser to ec2 instance](./images/ec2_script_5.png)

## Verify each user was added to developer group with .ssh folder and authorized_keys file created

Run the id command from the instance's command line to view the user and group information created for the new_user account:

```id```

The id command returns information similar to the following:

```
uid=1004(new_user) gid=1004(new_user) groups=1004(new_user)
```

![user id display](./images/ec2_script_6.png)

go to .ssh folder on the newuser home directory

```cd .ssh```

display contents of the authorized_keys file

```cat authorized_keys```

![authorized_keys display](./images/ec2_script_7.png)

you should see text similar to the public key above displayed on your screen.

Congratulations!