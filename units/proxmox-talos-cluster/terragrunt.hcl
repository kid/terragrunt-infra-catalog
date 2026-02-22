include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kid/terragrunt-infra-catalog//modules/proxmox-talos-cluster?ref=${values.version}"
}

inputs = {
  # Required inputs
  nodes       = values.nodes
  dhcp_server = values.dhcp_server
}
