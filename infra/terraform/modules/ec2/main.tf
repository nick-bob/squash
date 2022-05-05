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

  owners = [var.ami_owner]
}

resource "aws_security_group" "this" {
  name        = var.app_name
  description = "Security group for ${var.app_name}"
  vpc_id      = var.vpc_id
  tags        = var.default_tags
}

resource "aws_security_group_rule" "this" {
  for_each                 = var.security_group_rules
  security_group_id        = aws_security_group.this.id
  type                     = each.value.type
  to_port                  = each.value.to_port
  from_port                = each.value.from_port
  protocol                 = each.value.protocol
  cidr_blocks              = try(each.value.cidr_blocks, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.app.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.app_security_group_ids
  key_name                    = var.ssh_key
  associate_public_ip_address = var.associate_public_ip
  iam_instance_profile        = var.iam_role

  root_block_device {
    encrypted = true
  }

  tags = merge(var.default_tags, {
    "Name" : var.app_name
  })
}

resource "aws_lb_target_group_attachment" "app" {
  count            = var.create_alb ? 1 : 0
  target_group_arn = aws_lb_target_group.app[0].arn
  target_id        = aws_instance.app.id
  port             = 80
}

resource "aws_lb_target_group" "app" {
  count    = var.create_alb ? 1 : 0
  name     = "${var.app_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "app" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.app[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[0].arn
  }
}

resource "aws_lb" "app" {
  count              = var.create_alb ? 1 : 0
  name               = "${var.app_name}-alb"
  load_balancer_type = "application"
  security_groups    = var.app_lb_sg_ids
  subnets            = var.public_subnets
}