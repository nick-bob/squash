data "aws_caller_identity" "current" {}

module "app" {
  source = "../../modules/ec2"

  app_name     = "squash"
  subnet_id    = element(data.terraform_remote_state.base.outputs.network.private_subnet_ids, 0)
  default_tags = var.default_tags
  vpc_id       = data.terraform_remote_state.base.outputs.network.vpc_id
  ami_owner = data.aws_caller_identity.current.account_id
  ami_name_expression = "squash-*"
  associate_public_ip = false
  security_group_rules = {
    ssh = {
      "type"        = "ingress"
      "description" = "Open SSH to home ip"
      "from_port"   = 0
      "to_port"     = 65535
      "protocol"    = "tcp"
      "cidr_blocks" = [data.terraform_remote_state.base.outputs.network.vpc.cidr_block]
    },
    outbound = {
      "type"        = "egress"
      "description" = "Open up outbound"
      "from_port"   = 0
      "to_port"     = 0
      "protocol"    = "-1"
      "cidr_blocks" = ["0.0.0.0/0"]
    }
  }
  ssh_key             = data.terraform_remote_state.base.outputs.key_pair.key_name
}