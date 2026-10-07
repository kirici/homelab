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
  source = "${get_parent_terragrunt_dir("root")}/modules//network"
}

locals {
  cluster = include.root.locals.cluster
}

inputs = {
  name        = local.cluster.network_name
  bridge_name = local.cluster.bridge_name
  cidr        = local.cluster.cidr
  lan_bridge  = local.cluster.lan_bridge
  nodes       = local.cluster.nodes
}
