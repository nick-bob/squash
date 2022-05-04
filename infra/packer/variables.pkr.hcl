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
  default = "vpc-04f414940238be42c"
}

variable "subnet" {
  type = string
  default = "subnet-0a7dee803e914bc40"
}

variable "bastion_ip" {
  type = string
  default = "18.207.103.245"
}

variable "bastion_username" {
  type = string
  default = "ubuntu"
}

variable "builder_username" {
  type = string
  default = "ec2-user"
}
