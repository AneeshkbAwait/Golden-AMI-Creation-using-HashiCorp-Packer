
# Golden-AMI-Creation-using-HashiCorp-Packer

Packer is HashiCorp's open-source tool for creating machine images from source configuration. Here I am creating a golden AMI for a demo application with Amazon Image by using Packer Image Builder.

### appscript.sh

This is a bash script create an 'index.php' demo website. We can use whatever application instead of this sample script.
```
#!/bin/bash

echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment
service sshd restart

echo "password123" | passwd root --stdin
sed  -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service sshd restart

yum install httpd php -y
systemctl enable httpd
systemctl restart httpd

cat <<EOF > /var/www/html/index.php
<?php
\$output = shell_exec('echo $HOSTNAME');
echo "<h1><center><pre>\$output</pre></center></h1>";
echo "<h1><center><pre>  Version 1  </pre></center></h1>";
?>
EOF
```
### variables.pkr.hcl
The variable file for packer, contains the required variables to build the image. Here, We are adding time stamp to images to differentiate them.
```
variable "project" {

  default = "Test"
}

variable "env" {

  default = "prod"
}

variable "region" {

  default = "ap-south-1"
}

locals {

  image-timestamp = "${formatdate("DD-MM-YYYY-hh-mm", timestamp())}"
}

locals {

  image-name = "${var.project}-${var.env}-${local.image-timestamp}"
}
```

### main.pkr.hcl
The packer build configuration. We are filtering latest AMI of Amazon Linux using appropriate filters here, and then builds the image.
```
source "amazon-ebs" "app" {

  ami_name      = "${local.image-name}"
  region        = "${var.region}"
  instance_type = "t2.micro"
  ssh_username  = "ec2-user"


  tags = {
    Name    = "${local.image-name}"
    project = "${var.project}"
    env     = "${var.env}"
  }

  source_ami_filter {

    filters = {
      virtualization-type = "hvm"
      name                = "amzn2-ami-kernel-*-x86_64-gp2"
      root-device-type    = "ebs"
    }
    owners      = ["amazon"]
    most_recent = true
  }

}

build {

  sources = ["source.amazon-ebs.app"]

  provisioner "shell" {
    script          = "appscript.sh"
    execute_command = "sudo  {{.Path}}"
  }

}
```

Executing this will construct an AMI of the php application with the use of latest Amazon Linux AMI filtered. Later, These AMI shall be used to deploy Ec2 Instances on demand.
