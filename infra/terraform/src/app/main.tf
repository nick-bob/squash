data "aws_caller_identity" "current" {}

module "app" {
  source = "../../modules/ec2"

  app_name      = "squash"
  subnet_id     = element(data.terraform_remote_state.base.outputs.network.private_subnet_ids, 0)
  default_tags  = var.default_tags
  vpc_id        = data.terraform_remote_state.base.outputs.network.vpc_id
  app_lb_sg_ids = [data.terraform_remote_state.base.outputs.network.alb_sg_id]
  app_security_group_ids = [
    data.terraform_remote_state.base.outputs.network.app_sg_id,
    data.terraform_remote_state.base.outputs.network.db_sg_id
  ]
  public_subnets = data.terraform_remote_state.base.outputs.network.public_subnet_ids
  ami_owner           = data.aws_caller_identity.current.account_id
  ami_name_expression = "squash-*"
  associate_public_ip = false
  create_alb          = true
  ssh_key             = data.terraform_remote_state.base.outputs.key_pair.key_name
}