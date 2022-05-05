locals {
  base_name = join("-", [var.app_name, var.environment])
  tags = {
    environment = var.environment
  }
}

resource "aws_launch_template" "app" {
  name_prefix          = join("-", [local.base_name, "lt"])
  image_id             = data.aws_ami.app.id
  instance_type        = var.instance_type
  key_name = data.terraform_remote_state.base.outputs.key_pair.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  } 
  vpc_security_group_ids = [
    data.terraform_remote_state.base.outputs.network.app_sg_id,
    data.terraform_remote_state.base.outputs.network.db_sg_id
  ]
}

resource "aws_autoscaling_group" "app" {
  name               = join("-", [local.base_name, "asg"])
  vpc_zone_identifier = data.terraform_remote_state.base.outputs.network.private_subnet_ids
  desired_capacity   = 1
  max_size           = 6
  min_size           = 1

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "app" {
  autoscaling_group_name = aws_autoscaling_group.app.id
  lb_target_group_arn    = aws_lb_target_group.app.arn
}

resource "aws_autoscaling_policy" "scale_up" {
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  policy_type            = "SimpleScaling"
  cooldown               = 300
  name                   = join("-", [local.base_name, "scale-up-policy"])
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_autoscaling_policy" "scale_down" {
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  policy_type            = "SimpleScaling"
  cooldown               = 300
  name                   = join("-", [local.base_name, "scale-down-policy"])
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name = join("-", [local.base_name, "alarm", "high"])
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = var.scale_up_threshold
  treat_missing_data        = "missing"
  ok_actions                = []
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_policy.scale_down.name
  }

  alarm_description = "Scale down when CPU utilization falles below ${var.scale_up_threshold}"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
  tags              = local.tags
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name = join("-", [local.base_name, "alarm", "low"])
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = var.scale_down_threshold
  treat_missing_data        = "missing"
  ok_actions                = []
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_policy.scale_down.name
  }

  alarm_description = "Scale down when CPU utilization falles below ${var.scale_down_threshold}"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
  tags              = local.tags
}

resource "aws_lb_target_group" "app" {
  name     = join("-", [local.base_name, "tg"])
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.base.outputs.network.vpc_id
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb" "app" {
  name               = join("-", [local.base_name, "alb"])
  load_balancer_type = "application"
  security_groups = [data.terraform_remote_state.base.outputs.network.alb_sg_id]
  subnets = data.terraform_remote_state.base.outputs.network.public_subnet_ids
}

resource "aws_ssm_parameter" "DB_USER" {
  name  = "SQUASH_HOSTNAME"
  type  = "String"
  value = "http://${aws_lb.app.dns_name}"
}