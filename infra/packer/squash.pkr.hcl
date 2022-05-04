packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "squash_app" {
  ami_name                     = "${var.app_name}-${uuidv4()}"
  instance_type                = "t3.micro"
  region                       = var.region
  vpc_id                       = var.vpc
  subnet_id                    = var.subnet
  ssh_bastion_host             = var.bastion_ip
  ssh_bastion_username         = var.bastion_username
  ssh_username                 = var.builder_username
  ssh_bastion_private_key_file = "id_rsa"
  source_ami_filter {
    most_recent = true
    owners      = ["137112412989"]
    filters = {
      name                = "amzn2-ami-kernel-5.10-hvm-2.0.20220426.0-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
  }
  tags = {
    Name = var.app_name
  }
}

build {
  name = "squash_app"
  sources = [
    "source.amazon-ebs.squash_app"
  ]
  provisioner "file" {
    source      = "squash.tgz"
    destination = "/tmp/app.tar.gz"
  }
  provisioner "shell" {
    inline = [
      "sudo yum update && sudo yum install docker -y",
      "sudo systemctl enable docker.service && sudo systemctl start docker.service",
      "sudo docker load < /tmp/app.tar.gz",
      "sudo docker run -d -p 8080:8080 --restart unless-stopped nick-bob/squash:latest",
      ""
    ]
  }

}
