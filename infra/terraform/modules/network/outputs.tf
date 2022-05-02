output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "internal_subnets_ids" {
  value = aws_subnet.internal.*.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "app_sg_id" {
  value = aws_security_group.app.id
}

output "alb_sg_id" {
  value = aws_security_group.app-alb.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "vpc" {
  value = aws_vpc.main
}