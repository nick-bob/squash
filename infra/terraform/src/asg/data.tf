data "aws_caller_identity" "current" {}

data "terraform_remote_state" "base" {
  backend = "local"

  config = {
    path = "../base/terraform.tfstate"
  }
}

data "aws_ami" "app" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name_expression]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [data.aws_caller_identity.current.account_id]
}