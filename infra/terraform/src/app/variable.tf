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