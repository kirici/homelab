data "template_file" "user_data" {
  for_each = toset(local.hostnames)

  template = file("${path.module}/../resources/cloud-init.yaml")

  vars = {
    hostname = each.value
    domain   = var.domain
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  for_each = toset(local.hostnames)

  name      = "cloudinit-${each.key}.iso"
  user_data = data.template_file.user_data[each.key].rendered
  pool      = "default"
}

resource "libvirt_network" "virtnet" {
  name = "${var.vm_name}_net"
  mode = "nat"
  domain =var.domain
  addresses = ["10.10.10.0/24"]
  dhcp {
    enabled = false
  }
}

resource "libvirt_volume" "base_volume" {
  name   = "base_image.qcow2"
  pool   = "default"
  format = "qcow2"
  source = var.image_source
}

resource "libvirt_volume" "domain_volume" {
  for_each = toset(local.hostnames)

  name   = "${each.value}_volume.qcow2"
  base_volume_id = libvirt_volume.base_volume.id
  pool           = "default"
  format         = "qcow2"
  size           = var.disk_size
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
    network_id = libvirt_network.virtnet.id
    addresses  = ["${var.base_ip}.${each.value + 10}"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.domain_volume[each.key].id
  }

  console {
    # type        = "tty0"
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    # type        = "vnc"
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
