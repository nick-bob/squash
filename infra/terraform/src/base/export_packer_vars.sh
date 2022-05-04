#!/usr/bin/env bash

packer_dir="../../../packer/"

terraform output -json | jq -r '.ssh_key.value.public_key_openssh' > id_rsa.pub
terraform output -json | jq -r '.ssh_key.value.private_key_openssh' > id_rsa
instance_id=`terraform output -json | jq -r '.bastion.value.aws_instance.id'`
vpc_id=`terraform output -json | jq -r '.network.value.vpc_id'`
subnet=`terraform output -json | jq -r '.network.value.private_subnet_ids[0]'`
bastion_ip=`terraform output -json | jq -r '.bastion.value.aws_instance.public_ip'`

chmod 0600 id_rsa

cat << EOF > variables.pkr.hcl
variable "app_name" {
  type = string
  default = "squash"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "vpc" {
  type = string
  default = "${vpc_id}"
}

variable "subnet" {
  type = string
  default = "${subnet}"
}

variable "bastion_ip" {
  type = string
  default = "${bastion_ip}"
}

variable "bastion_username" {
  type = string
  default = "ubuntu"
}

variable "builder_username" {
  type = string
  default = "ec2-user"
}
EOF

mv variables.pkr.hcl $packer_dir
mv id_rsa* $packer_dir