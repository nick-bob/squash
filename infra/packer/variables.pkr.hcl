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
  default = "vpc-004af61a5d073be82"
}

variable "subnet" {
  type = string
  default = "subnet-08717351179d80471"
}

variable "bastion_ip" {
  type = string
  default = "44.204.213.6"
}

variable "bastion_username" {
  type = string
  default = "ubuntu"
}

variable "builder_username" {
  type = string
  default = "ec2-user"
}
