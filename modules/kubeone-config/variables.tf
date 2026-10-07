variable "base_manifest" {
  type        = string
  description = "KubeOneCluster YAML without hosts or apiEndpoint"
}

variable "nodes" {
  type = map(object({
    ip   = string
    role = string
  }))
}

variable "ssh_user" {
  type = string
}

variable "ssh_private_key_file" {
  type = string
}

variable "output_path" {
  type = string
}
