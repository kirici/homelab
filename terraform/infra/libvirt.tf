data "template_file" "user_data" {
  template = file("${path.module}/../resources/cloud-init.yaml")

  vars = {
    hostname = var.vm_name
    domain   = var.domain
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
  pool      = "default"
}

resource "libvirt_volume" "base_volume" {
  name   = "base_image.qcow2"
  pool   = "default"
  format = "qcow2"
  source = var.image_source
}

resource "libvirt_volume" "domain_volume" {
  name           = "node_volumes.qcow2"
  base_volume_id = libvirt_volume.base_volume.id
  pool           = "default"
  format         = "qcow2"
  size           = var.disk_size
}

resource "libvirt_domain" "node" {
  name       = var.vm_name
  memory     = var.memory
  vcpu       = var.cpu
  cloudinit  = libvirt_cloudinit_disk.cloudinit.id
  qemu_agent = true

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.domain_volume.id
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

output "ip" {
  value = libvirt_domain.node.network_interface[0].addresses[0]
}
