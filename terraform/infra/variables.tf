variable "image_source" {
  type    = string
  default = "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
}

variable "vm_name" {
  type    = string
  default = "node"
}

variable "domain" {
  type    = string
  default = "k8s.local"
}

variable "base_ip" {
  type    = string
  default = "10.10.10"
}

variable "memory" {
  type    = string
  default = "8192"
}

variable "cpu" {
  type    = number
  default = 2
}

variable "disk_size" {
  type    = number
  default = 30 * 1024 * 1024 * 1024
}

variable "extra_disk_size" {
  type    = number
  default = 15 * 1024 * 1024 * 1024
}

variable "node_count" {
  type    = number
  default = 1
}
