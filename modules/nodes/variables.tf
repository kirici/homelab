variable "nodes" {
  type = map(object({
    role       = string
    ip         = string
    mac        = string
    vcpu       = number
    memory_mib = number
    disk_gib   = number
  }))

  validation {
    condition     = length([for n in var.nodes : n if n.role == "control_plane"]) == 1
    error_message = "Exactly one control_plane node is supported: with no load balancer in front, a second one would have no stable API endpoint."
  }

  validation {
    condition     = alltrue([for n in var.nodes : contains(["control_plane", "worker"], n.role)])
    error_message = "role must be control_plane or worker."
  }
}

variable "pool" {
  type = string
}

variable "base_volume_path" {
  type = string
}

variable "network" {
  type = string
}

variable "lan_network" {
  type    = string
  default = null
}

variable "ssh_public_key" {
  type = string
}
