output "network" {
  value = module.network
}

output "bastion" {
  value = module.bastion
}

output "ssh_key" {
  value     = module.ssh_key.private_key
  sensitive = true
}

output "key_pair" {
  value = module.ssh_key.key_pair
}