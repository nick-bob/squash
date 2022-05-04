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
  default = "vpc-08092cc1663b9636d"
}

variable "subnet" {
  type = string
  default = "subnet-072972674f8dcaaec"
}

variable "bastion_ip" {
  type = string
  default = "3.231.50.253"
}

variable "bastion_username" {
  type = string
  default = "ubuntu"
}

variable "builder_username" {
  type = string
  default = "ec2-user"
}
