locals {
  hostnames = [for i in range(var.node_count) : "${var.vm_name}-${i + 1}"]
}
