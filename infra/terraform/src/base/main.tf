locals {
  subnets = [for cidr_block in cidrsubnets(var.vpc_cidr, 4, 4, 4) : cidrsubnets(cidr_block, 6, 6, 6)]
  public_subnets = {
    "subnets" : local.subnets[0]
    "availability_zones" : ["${var.region}a", "${var.region}b", "${var.region}c"]
  }
  private_subnets = {
    "subnets" : local.subnets[1]
    "availability_zones" : ["${var.region}a", "${var.region}b", "${var.region}c"]
  }
  internal_subnets = {
    "subnets" : local.subnets[2]
    "availability_zones" : ["${var.region}a", "${var.region}b", "${var.region}c"]
  }
  name = join("-", [var.org, var.project, var.environment])
  default_tags = {
    org         = var.org
    project     = var.project
    environment = var.environment
  }
}

module "ssh_key" {
  source       = "../../modules/key"
  key_name     = local.name
  default_tags = local.default_tags
}

module "network" {
  source = "../../modules/network"

  vpc_cidr         = var.vpc_cidr
  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  internal_subnets = local.internal_subnets
  default_tags     = local.default_tags
  vpc_name         = local.name
}

module "bastion" {
  source = "../../modules/ec2"

  app_name     = "bastion"
  subnet_id    = element(module.network.public_subnet_ids, 0)
  default_tags = var.default_tags
  vpc_id       = module.network.vpc_id
  security_group_rules = {
    ssh = {
      "type"        = "ingress"
      "description" = "Open SSH to home ip"
      "from_port"   = 22
      "to_port"     = 22
      "protocol"    = "tcp"
      "cidr_blocks" = var.cidr_whitelist
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
  ssh_key             = module.ssh_key.key_pair.key_name
  associate_public_ip = true
}

module "db" {
  source = "../../modules/db"
  db_name = "squash_db"
  username = "postgres"
  subnets = module.network.private_subnet_ids
  default_tags = local.default_tags
  security_group_ids = [module.network.db_sg_id]
}

resource "aws_ssm_parameter" "DB_USER" {
  name  = "SQUASH_DB_USER"
  type  = "String"
  value = "postgres"
}

resource "aws_ssm_parameter" "DB_PASSWORD" {
  name  = "SQUASH_DB_PASSWORD"
  type  = "String"
  value = module.db.password
}

resource "aws_ssm_parameter" "DB_HOST" {
  name  = "SQUASH_DB_HOST"
  type  = "String"
  value = module.db.db[0].address
}