variable "environment" {
  default = "development"
}

variable "ami_name_expression" {
  default = "squash-*"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "app_name" {
  default = "squash"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "scale_up_threshold" {
  type = number
  default = 85
}

variable "scale_down_threshold" {
  type = number
  default = 35
}

variable "scale_up_scaling_adjustment" {
  type = number
  default = 1
}

variable "scale_up_adjustment_type" {
  type = string
  default = "ChangeInCapacity"
}

variable "scale_down_scaling_adjustment" {
  type = number
  default = -1
}

variable "scale_down_adjustment_type" {
  type = string
  default = "ChangeInCapacity"
}