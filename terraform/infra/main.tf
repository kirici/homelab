terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
  # alias = "homelab"
  # uri   = "qemu+ssh://root@192.168.178.100/system"
}
