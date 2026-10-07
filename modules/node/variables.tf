variable "name" {
  type = string
}

variable "mac" {
  type = string
}

variable "vcpu" {
  type = number
}

variable "memory_mib" {
  type = number
}

variable "disk_gib" {
  type = number
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
