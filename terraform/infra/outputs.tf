output "vm_names" {
  description = "Names of created VMs"
  value       = [for domain in libvirt_domain.node : domain.name]
}

output "vm_ips" {
  description = "IP addresses of created VMs"
  value = {
    for name, domain in libvirt_domain.node : 
    name => domain.network_interface[0].addresses[0]
  }
}

output "network_name" {
  description = "Name of the created virtual network"
  value       = libvirt_network.virtnet.name
}
