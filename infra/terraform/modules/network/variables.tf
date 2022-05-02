variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = map(any)
}

variable "private_subnets" {
  type = map(any)
}

variable "internal_subnets" {
  type = map(any)
}

variable "vpc_name" {
  type = string
}

variable "default_tags" {
  type = map(any)
}