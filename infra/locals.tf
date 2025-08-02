locals {
  hostnames = [for i in range(var.node_count) : "${var.vm_name}-${i + 1}"]

  # Parse network CIDR
  network_parts = split(".", split("/", var.network_cidr)[0])
  base_ip       = "${local.network_parts[0]}.${local.network_parts[1]}.${local.network_parts[2]}"

  # Convert GB to bytes
  disk_size_bytes       = var.disk_size_gb * 1024 * 1024 * 1024
  extra_disk_size_bytes = var.extra_disk_size_gb * 1024 * 1024 * 1024
}
