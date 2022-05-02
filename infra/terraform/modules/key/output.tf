output "private_key" {
  value = tls_private_key.default
}

output "key_pair" {
  value = aws_key_pair.default
}