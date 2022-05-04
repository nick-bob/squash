output "password" {
  value = random_password.password.result
}

output "db" {
  value = aws_db_instance.db
}