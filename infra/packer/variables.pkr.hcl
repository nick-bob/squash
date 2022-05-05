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
  default = "vpc-0d90b403fcf6a00c2"
}

variable "subnet" {
  type = string
  default = "subnet-0e243d3964054b25a"
}

variable "bastion_ip" {
  type = string
  default = "54.235.41.247"
}

variable "bastion_username" {
  type = string
  default = "ubuntu"
}

variable "builder_username" {
  type = string
  default = "ec2-user"
}
