include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/modules//kubeone-config"
}

locals {
  cluster = include.root.locals.cluster
  root    = get_parent_terragrunt_dir("root")
}

dependency "nodes" {
  config_path = "../nodes"

  mock_outputs = {
    nodes = {
      mock-cp = { ip = "10.0.0.1", role = "control_plane" }
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  base_manifest        = file("${local.root}/kubeone/kubeone.base.yaml")
  nodes                = dependency.nodes.outputs.nodes
  ssh_user             = local.cluster.ssh_user
  ssh_private_key_file = local.cluster.ssh_private_key_file
  output_path          = "${local.root}/.state/kubeone.yaml"
}
