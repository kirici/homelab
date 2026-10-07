terraform {
  required_version = ">= 1.8"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.9"
    }
  }
}

# A dedicated pool keeps cluster disks apart from the host's other VMs, so a destroy here can never touch
# them. delete = false leaves the directory in place on destroy.
resource "libvirt_pool" "this" {
  name = var.pool_name
  type = "dir"

  target = {
    path = var.pool_path
  }

  create = {
    build     = true
    start     = true
    autostart = true
  }

  destroy = {
    delete = false
  }
}

# Base image for every node. Nodes get copy-on-write overlays on top of it and never write to it directly.
resource "libvirt_volume" "base" {
  name = var.image_name
  pool = libvirt_pool.this.name

  create = {
    content = {
      url = var.image_url
    }
  }

  target = {
    format = {
      type = "qcow2"
    }
  }
}
