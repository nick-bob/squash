output "aws_security_group" {
  value = aws_security_group.this
}

output "aws_security_group_rules" {
  value = aws_security_group_rule.this
}

output "aws_instance" {
  value = aws_instance.app
}

output "app_alb_target_group" {
  value = aws_lb_target_group.app
}

output "app_alb_listener" {
  value = aws_lb_listener.app
}

output "app_alb" {
  value = aws_lb.app
}