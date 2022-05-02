variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "org" {
  type    = string
  default = "cdc"
}

variable "project" {
  type    = string
  default = "blockchain"
}

variable "environment" {
  type    = string
  default = "development"
}


variable "default_tags" {
  type = map(any)
  default = {
    "env" : "development"
  }
}

variable "cidr_whitelist" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
