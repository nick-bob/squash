variable "db_name" {
  type = string
}

variable "username" {
  type    = string
  default = "postgres"
}

variable "subnets" {
  type = list(string)
}

variable "default_tags" {
  type = map(any)
}

variable "engine" {
  default = "postgres"
}

variable "security_group_ids" {
  type = list(string)
}

variable "create" {
  default = true
}

variable "name" {
  default = "app-postgres"
}

variable "multi_az" {
  default = true
}

variable "skip_final_snapshot" {
  default = true
}