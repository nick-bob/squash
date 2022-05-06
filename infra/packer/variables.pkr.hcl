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
  default = "vpc-0137c422b74568ccd"
}

variable "subnet" {
  type = string
  default = "subnet-09e3a03f5fc4aaf56"
}

variable "bastion_ip" {
  type = string
  default = "3.231.207.44"
}

variable "bastion_username" {
  type = string
  default = "ubuntu"
}

variable "builder_username" {
  type = string
  default = "ec2-user"
}
