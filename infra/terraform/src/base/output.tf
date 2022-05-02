output "vpc" {
  value = module.network.vpc
}

output "private_subnets" {
  value = module.network.private_subnet_ids
}

output "bastion" {
  value = module.bastion
}

output "ssh_key" {
  value = module.ssh_key.private_key
  sensitive = true
}

output "key_pair" {
  value = module.ssh_key.key_pair
}