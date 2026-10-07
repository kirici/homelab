terraform {
  required_version = ">= 1.8"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.9"
    }
  }
}

locals {
  # Second NIC gets a MAC derived from the first so the pair is always predictable.
  lan_mac = var.lan_network == null ? null : replace(var.mac, "52:54:00:", "52:54:01:")

  user_data = "#cloud-config\n${yamlencode({
    hostname         = var.name
    manage_etc_hosts = true
    ssh_pwauth       = false
    # Top-level keys land on the image's default user, which already has passwordless sudo.
    ssh_authorized_keys = [var.ssh_public_key]
  })}"

  # Matching on MAC keeps this independent of predictable interface naming (enp1s0 and friends).
  network_config = yamlencode({
    version = 2
    ethernets = merge(
      {
        nat = {
          match = { macaddress = var.mac }
          dhcp4 = true
        }
      },
      var.lan_network == null ? {} : {
        # Without this the LAN NIC would install a second default route that bypasses the cluster network.
        lan = {
          match          = { macaddress = local.lan_mac }
          dhcp4          = true
          dhcp4-overrides = { use-routes = false, use-dns = false }
        }
      },
    )
  })
}

# Anything that should produce a fresh disk (and therefore a fresh cloud-init run) is tracked here.
# cloud-init only applies user-data on a disk's first boot, so editing it in place would silently do nothing.
resource "terraform_data" "system_volume" {
  triggers_replace = {
    name           = var.name
    capacity       = var.disk_gib
    user_data      = sha256(local.user_data)
    network_config = sha256(local.network_config)
    base           = var.base_volume_path
  }
}

resource "libvirt_volume" "system" {
  name     = "${var.name}-system.qcow2"
  pool     = var.pool
  capacity = var.disk_gib * 1024 * 1024 * 1024

  backing_store = {
    path = var.base_volume_path
    format = {
      type = "qcow2"
    }
  }

  target = {
    format = {
      type = "qcow2"
    }
  }

  lifecycle {
    # The provider rejects in-place volume updates, so replacement is driven solely by terraform_data above.
    ignore_changes       = all
    replace_triggered_by = [terraform_data.system_volume]
  }
}

resource "libvirt_cloudinit_disk" "this" {
  name           = "${var.name}-cloudinit"
  user_data      = local.user_data
  network_config = local.network_config
  meta_data = yamlencode({
    instance-id    = var.name
    local-hostname = var.name
  })
}

# The seed ISO lives in the pool so it carries the same ownership and labels as the disks qemu already
# opens.
resource "libvirt_volume" "cloudinit" {
  name = "${var.name}-cloudinit.iso"
  pool = var.pool

  create = {
    content = {
      url = libvirt_cloudinit_disk.this.path
    }
  }

  target = {
    format = {
      type = "raw"
    }
  }

  lifecycle {
    ignore_changes       = all
    replace_triggered_by = [terraform_data.system_volume]
  }
}

resource "libvirt_domain" "this" {
  name        = var.name
  type        = "kvm"
  memory      = var.memory_mib
  memory_unit = "MiB"
  vcpu        = var.vcpu
  running     = true
  autostart   = true

  os = {
    type         = "hvm"
    boot_devices = [
      { dev = "hd" },
    ]
  }

  features = {
    acpi = true
  }

  # Without host-passthrough KVM guests get a baseline qemu64 CPU, which lacks instructions that some
  # container images and the eBPF datapath expect.
  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        driver = {
          name = "qemu"
          type = "qcow2"
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        source = {
          volume = {
            pool   = libvirt_volume.system.pool
            volume = libvirt_volume.system.name
          }
        }
      },
      {
        # q35 has no IDE controller, so the seed ISO goes on SATA.
        device = "cdrom"
        driver = {
          name = "qemu"
          type = "raw"
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit.pool
            volume = libvirt_volume.cloudinit.name
          }
        }
      },
    ]

    interfaces = concat(
      [{
        model  = { type = "virtio" }
        source = { network = { network = var.network } }
        mac    = { address = var.mac }
      }],
      var.lan_network == null ? [] : [{
        model  = { type = "virtio" }
        source = { network = { network = var.lan_network } }
        mac    = { address = local.lan_mac }
      }],
    )

    consoles = [{
      type        = "pty"
      target_type = "virtio"
    }]
  }

  lifecycle {
    # A replaced disk with the old domain definition still attached would boot the previous generation.
    replace_triggered_by = [
      libvirt_volume.system.id,
      libvirt_volume.cloudinit.id,
    ]
  }
}
