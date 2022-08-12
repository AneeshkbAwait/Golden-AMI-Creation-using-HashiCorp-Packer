variable "project" {

  default = "zomato"
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
