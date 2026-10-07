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
  source = "${get_parent_terragrunt_dir("root")}/modules//image"
}

locals {
  cluster = include.root.locals.cluster
}

inputs = {
  pool_name  = local.cluster.pool_name
  pool_path  = local.cluster.pool_path
  image_name = local.cluster.image_name
  image_url  = local.cluster.image_url
}
