variable "app_name" {
  type = string
  default = "squash"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "vpc" {
  type = string
  default = "vpc-01e26a7ad7fc4b948"
}

variable "subnet" {
  type = string
  default = "subnet-0f41e4b400498dc10"
}

variable "bastion_host" {
  type = string
  default = "3.231.24.255"
}

variable "bastion_username" {
  type = string
  default = "ubuntu"
}

variable "builder_username" {
  type = string
  default = "ec2-user"
}
