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
    script          = "setup.sh"
    execute_command = "sudo  {{.Path}}"
  }

}
