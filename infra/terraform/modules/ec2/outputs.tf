output "aws_security_group" {
  value = aws_security_group.this
}

output "aws_security_group_rules" {
  value = aws_security_group_rule.this
}

output "aws_instance" {
  value = aws_instance.app
}