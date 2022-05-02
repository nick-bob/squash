packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "btc_node" {
  ami_name                     = "btc-node"
  instance_type                = "t3.micro"
  region                       = "us-east-1"
  ssh_username                 = "ubuntu"
  vpc_id                       = "vpc-026c2d9f94de6fcd0"
  subnet_id                    = "subnet-07879f61e0f467c70"
  ssh_bastion_host             = "3.220.167.20"
  ssh_bastion_username         = "ubuntu"
  ssh_bastion_private_key_file = "~/.ssh/id_rsa"
  source_ami_filter {
    most_recent = true
    owners      = ["099720109477"]
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
  }
}

build {
  name = "btc_node"
  sources = [
    "source.amazon-ebs.btc_node"
  ]
  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    ssh_authorized_key_file = "/Users/nick/.ssh/id_rsa.pub"
    ansible_ssh_extra_args = ["-o StrictHostKeyChecking=no -o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s -o ProxyCommand='ssh -i ~/.ssh/id_rsa -W %h:%p ubuntu@3.220.167.20'"]
  }
}
