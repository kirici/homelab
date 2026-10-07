# Consumed by the kubeone-config unit and by the nodes:wait task.
output "nodes" {
  value = { for k, n in var.nodes : k => { ip = n.ip, role = n.role } }
}
