resource "aws_launch_template" "app" {
  name_prefix   = "example"
  image_id      = data.aws_ami.example.id
  instance_type = "c5.large"
}

resource "aws_autoscaling_group" "app" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "app" {
  autoscaling_group_name = "my-test-asg"
  name                   = "foo"
  policy_type            = "PredictiveScaling"
  predictive_scaling_configuration {
    metric_specification {
      target_value = 10
      predefined_load_metric_specification {
        predefined_metric_type = "ASGTotalCPUUtilization"
        resource_label         = "testLabel"
      }
      customized_scaling_metric_specification {
        metric_data_queries {
          id = "scaling"
          metric_stat {
            metric {
              metric_name = "CPUUtilization"
              namespace   = "AWS/EC2"
              dimensions {
                name  = "AutoScalingGroupName"
                value = "my-test-asg"
              }
            }
            stat = "Average"
          }
        }
      }
    }
  }
}

resource "aws_autoscaling_attachment" "app" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.test.arn
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app[0].arn
  target_id        = aws_instance.app.id
  port             = 80
}

resource "aws_lb_target_group" "app" {
  name     = "${var.app_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[0].arn
  }
}

resource "aws_lb" "app" {
  name               = "${var.app_name}-alb"
  load_balancer_type = "application"
  security_groups    = var.app_lb_sg_ids
  subnets            = var.public_subnets
}