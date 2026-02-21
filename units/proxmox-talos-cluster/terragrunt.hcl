include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kid/terragrunt-infra-catalog//modules/proxmox-talos-cluster?ref=${values.version}"
}

include "provider_proxmox" {
  path = "${get_repo_root()}/modules/_shared/provider-proxmox.hcl"
}

include "provider_routeros" {
  path = "${get_repo_root()}/modules/_shared/provider-routeros.hcl"
}

inputs = {
  # Required inputs
  nodes       = values.nodes
  dhcp_server = values.dhcp_server
}
