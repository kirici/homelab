terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
  # alias = "homelab"
  # uri   = "qemu+ssh://root@192.168.178.100/system"
}
