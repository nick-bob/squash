resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(var.default_tags, {
    "Name" : var.vpc_name
  })
}

resource "aws_subnet" "public" {
  count             = length(lookup(var.public_subnets, "subnets", null))
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(lookup(var.public_subnets, "subnets", null), count.index)
  availability_zone = element(lookup(var.public_subnets, "availability_zones", null), count.index)

  tags = merge(var.default_tags, {
    "Name" : "public-subnet-${count.index}",
    "type" : "public"
  })
}

resource "aws_subnet" "private" {
  count             = length(lookup(var.private_subnets, "subnets", null))
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(lookup(var.private_subnets, "subnets", null), count.index)
  availability_zone = element(lookup(var.private_subnets, "availability_zones", null), count.index)

  tags = merge(var.default_tags, {
    "Name" : "private-subnet-${count.index}",
    "type" : "private"
  })
}

resource "aws_subnet" "internal" {
  count             = length(lookup(var.internal_subnets, "subnets", null))
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(lookup(var.internal_subnets, "subnets", null), count.index)
  availability_zone = element(lookup(var.internal_subnets, "availability_zones", null), count.index)

  tags = merge(var.default_tags, {
    "Name" : "internal-subnet-${count.index}",
    "type" : "internal"
  })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.default_tags, {
    "Name" : "InternetGateway"
  })
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.default_tags, {
    "Name" : "NatGateway"
  })
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.default_tags, {
    "Name" : "public-rtb"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.default_tags, {
    "Name" : "private-rtb"
  })
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
  depends_on             = [aws_internet_gateway.gw]
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
  depends_on             = [aws_nat_gateway.nat]
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Security Group for bastion host"
  vpc_id      = aws_vpc.main.id

  egress = [
    {
      description      = "Outbound traffic for ingress"
      prefix_list_ids  = null
      security_groups  = null
      self             = null
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
  ingress = [
    {
      description      = "Open SSH"
      prefix_list_ids  = null
      security_groups  = null
      self             = null
      from_port        = 22
      to_port          = 22
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = merge(var.default_tags, {
    "Name" : "app-sg"
  })
}

resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Security Group for web applications"
  vpc_id      = aws_vpc.main.id

  egress = [
    {
      description      = "Outbound traffic for app"
      prefix_list_ids  = null
      security_groups  = null
      self             = null
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = merge(var.default_tags, {
    "Name" : "app-sg"
  })
}

resource "aws_security_group" "app-alb" {
  name        = "alb-sg"
  description = "Security Group for application load balancers"
  vpc_id      = aws_vpc.main.id

  tags = merge(var.default_tags, {
    "Name" : "alb-sg"
  })
}

resource "aws_security_group" "db" {
  name        = "postgres-sg"
  description = "Security group for Postgres running on RDS"
  vpc_id      = aws_vpc.main.id
  tags = merge(var.default_tags, {
    "Name" : "db-sg"
  })
}

resource "aws_security_group_rule" "alb-to-app-ing" {
  type                     = "ingress"
  to_port                  = 80
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.app-alb.id
}

resource "aws_security_group_rule" "app-to-db-ing" {
  type                     = "ingress"
  to_port                  = 5432
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "bastion-to-app" {
  type                     = "ingress"
  to_port                  = 22
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "db-to-app-ing" {
  type                     = "ingress"
  to_port                  = 5432
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.db.id
}

resource "aws_security_group_rule" "db-egr" {
  type                     = "egress"
  to_port                  = 5432
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "alb-ing" {
  type              = "ingress"
  to_port           = 80
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.app-alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb-egr" {
  type                     = "egress"
  to_port                  = 80
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app-alb.id
  source_security_group_id = aws_security_group.app.id
}

