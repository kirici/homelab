terraform {
  required_version = ">= 1.8"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.9"
    }
  }
}

module "node" {
  source   = "../node"
  for_each = var.nodes

  name             = each.key
  mac              = each.value.mac
  vcpu             = each.value.vcpu
  memory_mib       = each.value.memory_mib
  disk_gib         = each.value.disk_gib
  pool             = var.pool
  base_volume_path = var.base_volume_path
  network          = var.network
  lan_network      = var.lan_network
  ssh_public_key   = var.ssh_public_key
}
