resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
  key_name   = var.key_name
  public_key = tls_private_key.default.public_key_openssh
  tags        = var.default_tags
}