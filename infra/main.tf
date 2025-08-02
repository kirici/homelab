data "cloudinit_config" "init" {
  for_each = { for idx, name in local.hostnames : name => idx }
  
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content = templatefile(var.cloud_init_template, {
      hostname = each.key
      domain   = var.domain
    })
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  for_each = { for idx, name in local.hostnames : name => idx }

  name      = "cloudinit-${each.key}.iso"
  pool      = var.storage_pool
  user_data = data.cloudinit_config.init[each.key].rendered
}

resource "libvirt_network" "virtnet" {
  name      = "${var.vm_name}-net"
  mode      = "nat"
  domain    = var.domain
  addresses = [var.network_cidr]
  
  dhcp {
    enabled = false
  }
}

resource "libvirt_volume" "base_volume" {
  name   = "${var.vm_name}-base.qcow2"
  pool   = var.storage_pool
  format = "qcow2"
  source = var.image_source
}

resource "libvirt_volume" "domain_volume" {
  for_each = toset(local.hostnames)

  name           = "${each.value}-root.qcow2"
  base_volume_id = libvirt_volume.base_volume.id
  pool           = var.storage_pool
  format         = "qcow2"
  size           = local.disk_size_bytes
}

resource "libvirt_volume" "block_volume" {
  for_each = toset(local.hostnames)

  name   = "${each.value}-data.qcow2"
  pool   = var.storage_pool
  format = "qcow2"
  size   = local.extra_disk_size_bytes
}

resource "libvirt_domain" "node" {
  for_each = { for idx, name in local.hostnames : name => idx }

  name       = each.key
  memory     = var.memory
  vcpu       = var.cpu
  cloudinit  = libvirt_cloudinit_disk.cloudinit[each.key].id
  qemu_agent = true

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_id     = libvirt_network.virtnet.id
    addresses      = ["${local.base_ip}.${each.value + 10}"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.domain_volume[each.key].id
  }

  disk {
    volume_id = libvirt_volume.block_volume[each.key].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
