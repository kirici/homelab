variable "name" {
  type = string
}

variable "bridge_name" {
  type        = string
  description = "Linux bridge name for the NAT network. Max 15 characters."
}

variable "cidr" {
  type = string
}

variable "lan_bridge" {
  type    = string
  default = null
}

variable "nodes" {
  type = map(object({
    ip  = string
    mac = string
  }))
}
