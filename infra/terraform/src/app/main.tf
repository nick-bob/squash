data "aws_caller_identity" "current" {}

resource "aws_iam_role" "squash" {
  name = "squash_app"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "squash_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameters",
            "ssm:GetParameter"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  tags = {
    Name = "squash_app"
  }
}

resource "aws_iam_instance_profile" "squash" {
  name = aws_iam_role.squash.name
  role = aws_iam_role.squash.name
}

resource "aws_ssm_parameter" "DB_USER" {
  name  = "SQUASH_HOSTNAME"
  type  = "String"
  value = "module.app.app_alb[0].dns_name"
}

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
  public_subnets      = data.terraform_remote_state.base.outputs.network.public_subnet_ids
  ami_owner           = data.aws_caller_identity.current.account_id
  ami_name_expression = "squash-*"
  associate_public_ip = var.associate_public_ip
  create_alb          = true
  ssh_key             = data.terraform_remote_state.base.outputs.key_pair.key_name
  iam_role            = aws_iam_instance_profile.squash.name
}