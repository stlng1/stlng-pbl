# Automate Infrastructure With IaC using Terraform Cloud

This report describes the automation with codes for deploying 2 company websites, using terraform for deploying infrastructure and ansible for applications. Kindly refer to the repository below for all codes/files related to this project.

**https://github.com/stlng1/terraform-cloud/tree/dev**

## Pre-requisites
---

1. Install the following pre-requisites:

        a. packer

        b. ansible

        c. AWS CLI

        d. graphviz and run

```terraform graph | dot -Tsvg > graph.svg```

![terraform](./images/p19_vsc_1.png)

1. Create a Terraform Cloud account

![terraform](./images/p19_web_01.png)


2. Create an organization

![terraform](./images/p19_web_01a.png)


3. Configure a workspace

![terraform](./images/p19_web_03.png)

![terraform](./images/p19_web_04.png)

![terraform](./images/p19_web_05.png)

![terraform](./images/p19_web_06.png)

5. Configure variables

![terraform](./images/p19_web_07.png)

Set two environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

![terraform](./images/p19_web_10.png)

![terraform](./images/p19_web_08.png)



# Action Plan for project 19
---

## Build images using packer
---

1. Export credentials

The AMI credentials is required to launch an EC2 Instance.

```export AWS_ACCESS_KEY_ID=AK************IEVXQ```

```export AWS_SECRET_ACCESS_KEY=gbaIbK*********************iwN0dGfS```

2. List the Latest Available RHEL Amazon Machine Images (AMIs)

 To obtain the RHEL AMIs list, we open our terminal and type the following command to list all RHEL-8 images that start with from the owner 309956199498 (RedHat).

```
aws ec2 describe-images --owners 309956199498 --query 'sort_by(Images, &CreationDate)[*].[CreationDate,Name,ImageId]' --filters "Name=name,Values=RHEL-9*" --region eu-west-3 --output table
```

and this is the result:

![ami](./images/p19_vsc_2.png)

3. update filters in **bastion.pkr.hcl** file with the name of the base image to start with, copied from step 2 above.

```
variable "region" {
  type    = string
  default = "eu-west-3"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioners and post-processors on a
# source.
source "amazon-ebs" "ami-bastion-prj-19" {
  ami_name      = "ami-bastion-prj-19-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "RHEL-8.7.0_HVM-20221101-x86_64-0-Hourly2-GP2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["309956199498"]
  }
  ssh_username = "ec2-user"
  tag {
    key   = "Name"
    value = "ami-bastion-prj-19"
  }
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.ami-bastion-prj-19"]

  provisioner "shell" {
    script = "bastion.sh"
  }
}
```

4. from the command line, run:

```packer build bastion.pkr.hcl```

![ami_images](./images/p19_vsc_3.png)

5. repeat steps 3 and 4 to create RHEL 8 images for the other packer files in the AMI directory - nginx.pkr.hcl and web.pkr.hcl.

![ami_images](./images/p19_vsc_3a.png)

![ami_images](./images/p19_vsc_3b.png)

For ubuntu.pkr.hcl, we have to repeat step 2 to retrieve the ubuntu base image for packer to create our image.

![ami_images](./images/p19_vsc_3c.png)


## Confirm the AMIs in the console
---

6. Log into yor AWS account to see the newly created images.

![ami_images](./images/p19_web_11.png)


## Create branches and workspaces 
---

7. create - dev, test and prod branches from main branch in github. you can create the branches in vscode and push to github.

![github](./images/p19_web_16.png)

8. create - DEV workspace on terraform cloud

![terraform cloud](./images/p19_web_12.png)

![terraform cloud](./images/p19_web_13.png)

![terraform cloud](./images/p19_web_14.png)

9. Configure terraform to trigger runs automatically only for dev environment

![terraform cloud](./images/p19_web_14a.png)

![terraform cloud](./images/p19_web_14b.png)

![terraform cloud](./images/p19_web_14c.png)

![terraform cloud](./images/p19_web_14d.png)

10. update variables by creating **variable sets** from tfvar files; 
*note: check 'HCL' for map string variables and other values returned error before editing your codes*
 create 3 variable sets as follows:

 a. environment_var_set: for environmental variables

 b. general_var_set: for general variables

 c. network_var_set: for network/compute variables

![terraform cloud variable set](./images/p19_web_17a.png)

11. apply the variable set to your workspace

![terraform cloud variable set](./images/p19_web_18.png)

12. repeat steps 8 and 11 above to create - **TEST** and **PROD** workspaces on terraform cloud

![terraform cloud](./images/p19_web_19.png)

## Trigger New Run

13. update new ami IDs generated from packer build above in the network_var_set variable set on terraform cloud. copy the ami_ids from AWS console.

![terraform cloud variable set](./images/p19_web_38.png)

14. commit and push codes to github to trigger a new run 

![terraform cloud variable set](./images/p19_web_39a.png)

![terraform cloud variable set](./images/p19_web_39b.png)

![terraform cloud variable set](./images/p19_web_39c.png)


## Create an Email and Slack Notifications for All Events
---

15. create email notifications from terraform cloud

![notifications](./images/p19_web_31.png)

![notifications](./images/p19_web_31a.png)

![notifications](./images/p19_web_31b.png)

![notifications](./images/p19_web_31c.png)

![notifications](./images/p19_web_31d.png)

## update ansible script with values from terraform output

16. copy the values from AWS console and paste on Ansible in vscode
      a. RDS endpoints for wordpress and tooling
      b. Database name, password and username for wordpress and tooling
      c. Access point ID for wordpress and tooling
      d. PrivateALB DNS for nginx reverse proxy

![ansible](./images/p19_web_42.png)

17. push the updated Ansible codes to github repository.

18. Ensure OpenSSH is installed on your local computer. configure ssh agent on your local computer from your vscode terminal. Use the following commands:

```
eval `ssh-agent`
```

```
ssh-add <path>/<keypair>.pem
```

19. Login to the newly created bastion sever on your terminal. Get the public ip from AWS console

```
ssh -A ec2-user@<server public_ip>
```

20. clone down your github repository *(dev branch)* into the bastion

```
git clone -b dev https://<repository url>
```

21. configure **ansible.cfg**. got to the ansible folder and update the roles_path to the current path on your bastion. (you can know your current path by typing **pwd** command)

open you ansible.cfg file with your prefered line editor

```
vi ansible.cfg
```

![ansible.cfg](./images/p19_web_40.png)

then export the configuration with the command below:

```
export ANSIBLE_CONFIG=<path to config file>/ansible.cfg
```

22. Configure the bastion to access your AWS account by providing your access key. Ansible requires this access for dynamic inventory updates. Use the following command

```
aws configure
```

23. Test access for updated aws inventory: 

```
ansible-inventory -i inventory/aws_ec2.yml --graph
```

output should be similar to this

![ansible](./images/p19_web_35.png)

24. run ansible script: 

```
ansible-playbook -i inventory/aws_ec2.yml playbooks/site.yml 
```

![ansible](./images/p19_web_36.png)

25. check the website

![ansible](./images/p19_web_37.png)

26. Apply destroy from Terraform Cloud web console

![terraform](./images/p19_web_41.png)


## TASK 2 - Working with Private repository

## Create a repository

1. to create a repository from a simple Terraform repository, fork repository - https://github.com/hashicorp/learn-private-module-aws-s3-webapp.git

2. In the newly forked repository, goto *settings* and check *Template repository* 

![repo](./images/p19_web_20.png)

![repo](./images/p19_web_20a.png)

3. get back to the code page and create new repository (private) as shown below:

![repo](./images/p19_web_20b.png)

![repo](./images/p19_web_20c.png)

![repo](./images/p19_web_20d.png)

## Configuring GitHub.com Access (OAuth)

4. Terraform Private Registry requires permissions, (OAuth verification) to access GitHub. To get required information for this access from terraform, follow the images below:

![OAuth](./images/p19_web_23.png)

![OAuth](./images/p19_web_23a.png)

![OAuth](./images/p19_web_23b.png)

![OAuth](./images/p19_web_23c.png)

Leave this page open 

5. On Github, we are going to input the information opened in step 5. follow the images below:

open profile settings from top right hand corner of the page

![OAuth](./images/p19_web_22.png)

goto **settings --> developer settings --> OAuth Apps**

![OAuth](./images/p19_web_22a.png)

![OAuth](./images/p19_web_22b.png)

![OAuth](./images/p19_web_22c.png)

6. upload terraform logo on the page and keep it open still..

7. generate client secret on the page and keep it open still..

![OAuth](./images/p19_web_22d.png)

8. get back to the Terraform page an input **client ID and Client Secret** on the page

![OAuth](./images/p19_web_23d.png)

Click "Connect and continue."

9. Finally, Authorize as shown below

![OAuth](./images/p19_web_23e.png)

![OAuth](./images/p19_web_23f.png)

## Import the module into your private registry

10. tag a release

![repo](./images/p19_web_21a.png)

![repo](./images/p19_web_21b.png)

![repo](./images/p19_web_21c.png)

![repo](./images/p19_web_21d.png)

11. import the module

![import](./images/p19_web_24a.png)

![import](./images/p19_web_24b.png)

![import](./images/p19_web_24c.png)

![import](./images/p19_web_24d.png)

notice the Usage Instructions section. You will use these as the building blocks for your workspace configuration

## Create a configuration that uses the module

12. created new configuration files to stored in public repository to utilize modules created earlier stored in private repository.

https://github.com/stlng1/hashi-tutorial-2.git

## Create a workspace for the configuration

13. create workspace and variables on terraform cloud

![import](./images/p19_web_25.png)

![import](./images/p19_web_26.png)

## Deploy the infrastructure

![deploy](./images/p19_web_27.png)

![deploy](./images/p19_web_28.png)

## Destroy your deployment

![destroy](./images/p19_web_29.png)

![destroy](./images/p19_web_29a.png)

![destroy](./images/p19_web_29b.png)

![destroy](./images/p19_web_30.png)