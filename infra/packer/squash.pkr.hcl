packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "squash_app" {
  ami_name                     = var.app_name
  instance_type                = "t3.micro"
  region                       = var.region
  vpc_id                       = var.vpc
  subnet_id                    = var.subnet
  ssh_bastion_host             = var.bastion_host
  ssh_bastion_username         = var.bastion_username
  ssh_username                 = var.builder_username
  ssh_bastion_private_key_file = "../id_rsa"
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
    source      = "squash_image.tgz"
    destination = "/tmp/app.tar.gz"
  }
  provisioner "ansible" {
    playbook_file           = "./playbook.yml"
    ssh_authorized_key_file = "../id_rsa.pub"
    ansible_ssh_extra_args  = ["-o StrictHostKeyChecking=no -o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s -o ProxyCommand='ssh -i ~/.ssh/id_rsa -W %h:%p ubuntu@3.231.24.255'"]
  }
}
