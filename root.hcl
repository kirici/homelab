# Included by every unit. State is local for now because nothing here holds secrets yet; revisit when a
# cluster unit starts writing kubeconfigs or certificates into state.

terraform_binary = "tofu"

locals {
  cluster = read_terragrunt_config(find_in_parent_folders("cluster.hcl")).locals
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

# Every unit talks to the same hypervisor, so the provider block lives here and the modules only
# declare the provider requirement.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOT
    provider "libvirt" {
      uri = "${local.cluster.libvirt_uri}"
    }
  EOT
}
