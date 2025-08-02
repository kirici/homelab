variable "libvirt_uri" {
  description = "Libvirt connection URI"
  type        = string
  default     = "qemu:///system"
  
  validation {
    condition     = can(regex("^qemu", var.libvirt_uri))
    error_message = "URI must start with 'qemu'."
  }
}

variable "image_source" {
  description = "Source path or URL for the base VM image"
  type        = string
  default     = "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
}

variable "vm_name" {
  description = "Base name for VMs (will be suffixed with -1, -2, etc.)"
  type        = string
  default     = "node"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.vm_name))
    error_message = "VM name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "domain" {
  description = "DNS domain for the virtual network"
  type        = string
  default     = "k8s.local"
}

variable "network_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
  default     = "10.10.10.0/24"
  
  validation {
    condition     = can(cidrhost(var.network_cidr, 0))
    error_message = "Network CIDR must be a valid CIDR block."
  }
}

variable "memory" {
  description = "Memory allocation in MB"
  type        = number
  default     = 8192
  
  validation {
    condition     = var.memory >= 512
    error_message = "Memory must be at least 512 MB."
  }
}

variable "cpu" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 2
  
  validation {
    condition     = var.cpu >= 1 && var.cpu <= 16
    error_message = "CPU count must be between 1 and 16."
  }
}

variable "disk_size_gb" {
  description = "Size of the main disk in GB"
  type        = number
  default     = 30
  
  validation {
    condition     = var.disk_size_gb >= 10
    error_message = "Disk size must be at least 10 GB."
  }
}

variable "extra_disk_size_gb" {
  description = "Size of the additional disk in GB"
  type        = number
  default     = 15
  
  validation {
    condition     = var.extra_disk_size_gb >= 1
    error_message = "Extra disk size must be at least 1 GB."
  }
}

variable "node_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "storage_pool" {
  description = "Libvirt storage pool name"
  type        = string
  default     = "default"
}

variable "cloud_init_template" {
  description = "Path to cloud-init template file"
  type        = string
  default     = "resources/cloud-init.yaml"
}
