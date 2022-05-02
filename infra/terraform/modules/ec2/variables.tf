variable "ami_name_expression" {
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "ami_owner" {
  default = "099720109477" # Canonical
}

variable "app_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "default_tags" {
  type = map(any)
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "app_lb_sg_id" {
  type    = string
  default = ""
}

variable "app_sg_id" {
  type    = string
  default = null
}

variable "create_alb" {
  type    = bool
  default = false
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_key" {
  type    = string
  default = "nbkey"
}

variable "associate_public_ip" {
  type    = bool
  default = false
}

variable "security_group_rules" {
  type    = map(any)
  default = {}
}