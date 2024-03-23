variable "vm_name" {
  type    = string
  default = "strim"
}

variable "domain" {
  type    = string
  default = "local"
}

variable "memory" {
  type    = string
  default = "8192"
}

variable "cpu" {
  type    = number
  default = 4
}

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

resource "libvirt_volume" "qcow_volume" {
  name = "centos-stream8.qcow2"
  pool = "default"
  # source = "https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2"
  source = "../resources/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2"
  format = "qcow2"
}

resource "libvirt_domain" "centos-stream8" {
  name       = var.vm_name
  memory     = var.memory
  vcpu       = var.cpu
  cloudinit  = libvirt_cloudinit_disk.cloudinit.id
  qemu_agent = true

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.qcow_volume.id
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

output "ip" {
  value = libvirt_domain.centos-stream8.network_interface[0].addresses[0]
}
