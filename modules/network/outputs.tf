output "network_name" {
  value = libvirt_network.nat.name
}

output "lan_network_name" {
  value = one(libvirt_network.lan[*].name)
}
