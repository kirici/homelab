terraform {
  required_version = ">= 1.8"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.9"
    }
  }
}

# KubeOne needs stable node addresses up front, so reservations keyed on fixed MACs are
# the whole addressing story. No dynamic range is defined: an unknown MAC gets no lease at all.
resource "libvirt_network" "nat" {
  name      = var.name
  autostart = true

  forward = {
    mode = "nat"
  }

  bridge = {
    name = var.bridge_name
  }

  ips = [{
    address = cidrhost(var.cidr, 1)
    prefix  = tonumber(split("/", var.cidr)[1])

    dhcp = {
      hosts = [for name, n in var.nodes : { name = name, mac = n.mac, ip = n.ip }]
    }
  }]
}

# Optional pass-through to an existing host bridge. libvirt does not create host bridges, so this only
# wraps one that NetworkManager (or similar) already set up.
resource "libvirt_network" "lan" {
  count     = var.lan_bridge == null ? 0 : 1
  name      = "${var.name}-lan"
  autostart = true

  forward = {
    mode = "bridge"
  }

  bridge = {
    name = var.lan_bridge
  }
}
