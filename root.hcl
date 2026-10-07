# Included by every unit. State is local for now because nothing here holds secrets yet; revisit when a
# cluster unit starts writing kubeconfigs or certificates into state.

terraform_binary = "tofu"

locals {
  cluster = read_terragrunt_config(find_in_parent_folders("cluster.hcl")).locals

  # Only units that talk to libvirt use this. Generating it everywhere would make tofu look for a
  # hashicorp/libvirt provider in modules that don't declare one.
  libvirt_provider = <<-EOT
    provider "libvirt" {
      uri = "${local.cluster.libvirt_uri}"
    }
  EOT
}

remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path = "${get_parent_terragrunt_dir()}/.state/${path_relative_to_include()}/terraform.tfstate"
  }
}
