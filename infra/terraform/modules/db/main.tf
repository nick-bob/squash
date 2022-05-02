resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%"
}

resource "aws_db_subnet_group" "postgres" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnets

  tags = var.default_tags
}

resource "aws_db_instance" "db" {
  count = var.create ? 1 : 0

  allocated_storage      = 10
  identifier             = var.name
  engine                 = var.engine
  instance_class         = "db.t3.micro"
  name                   = var.db_name
  username               = var.username
  password               = random_password.password.result
  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  skip_final_snapshot    = var.skip_final_snapshot
  vpc_security_group_ids = var.security_group_ids

  tags = merge(var.default_tags, {
    "Name" : var.name
  })
}