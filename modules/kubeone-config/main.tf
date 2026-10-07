terraform {
  required_version = ">= 1.8"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

locals {
  base          = yamldecode(var.base_manifest)
  control_plane = sort([for k, n in var.nodes : k if n.role == "control_plane"])
  workers       = sort([for k, n in var.nodes : k if n.role == "worker"])

  # One shape for both groups; KubeOne takes the same host fields under controlPlane and staticWorkers.
  host = { for k, n in var.nodes : k => {
    hostname          = k
    publicAddress     = n.ip
    privateAddress    = n.ip
    sshPort           = 22
    sshUsername       = var.ssh_user
    sshPrivateKeyFile = var.ssh_private_key_file
  } }

  manifest = merge(local.base, {
    # A single control plane has no load balancer, so the API endpoint is the node itself.
    apiEndpoint = {
      host = var.nodes[local.control_plane[0]].ip
      port = 6443
    }
    controlPlane  = { hosts = [for k in local.control_plane : local.host[k]] }
    staticWorkers = { hosts = [for k in local.workers : local.host[k]] }
  })
}

# Generated file, so comments from the base manifest are not preserved. Edit the base, not this.
resource "local_file" "manifest" {
  filename        = var.output_path
  content         = yamlencode(local.manifest)
  file_permission = "0644"
}
