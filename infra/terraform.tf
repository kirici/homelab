terraform {
  required_version = ">= 1.9.1"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.7"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.5.3"
    }
  }
}
