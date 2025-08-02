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

output "hosts_entries" {
  description = "Entries for /etc/hosts file"
  value = join("\n", [
    for name, domain in libvirt_domain.node :
    "${domain.network_interface[0].addresses[0]} ${name}"
  ])
}

output "k0s_hosts" {
  description = "Host information for k0sctl config"
  value = [
    for idx, name in local.hostnames : {
      name = name
      ip   = libvirt_domain.node[name].network_interface[0].addresses[0]
      role = idx == 0 ? "controller" : "worker"
    }
  ]
}

resource "local_file" "k0sctl_config" {
  content = templatefile("${path.module}/templates/k0sctl.yaml.tpl", {
    hosts = [
      for idx, name in local.hostnames : {
        name = name
        ip   = libvirt_domain.node[name].network_interface[0].addresses[0]
        role = idx == 0 ? "controller" : "worker"
      }
    ]
  })
  filename = "${path.module}/k0sctl.yaml"
}

output "k0sctl_config_path" {
  description = "Path to generated k0sctl config"
  value       = local_file.k0sctl_config.filename
}
