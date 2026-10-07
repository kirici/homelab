include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = include.root.locals.libvirt_provider
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/modules//nodes"
}

locals {
  cluster = include.root.locals.cluster
}

# Mocks let `run --all plan` work on a machine where nothing has been applied yet.
dependency "image" {
  config_path = "../image"

  mock_outputs = {
    pool_name        = "mock-pool"
    base_volume_path = "/mock/base.qcow2"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    network_name = "mock-net"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  nodes            = local.cluster.nodes
  pool             = dependency.image.outputs.pool_name
  base_volume_path = dependency.image.outputs.base_volume_path
  network          = dependency.network.outputs.network_name
  # Terragrunt omits null outputs entirely, so a plain attribute lookup fails when lan_bridge is unset.
  lan_network    = try(dependency.network.outputs.lan_network_name, null)
  ssh_public_key = local.cluster.ssh_public_key
}
