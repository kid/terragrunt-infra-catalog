include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kid/terragrunt-infra-catalog//modules/proxmox-ros-lab?ref=${values.version}"
}

include "provider_proxmox" {
  path = "${get_repo_root()}/modules/_shared/provider-proxmox.hcl"
}

inputs = {
  # Required inputs
  devices          = values.devices
  op_vault         = values.op_vault
  op_item_routeros = values.op_item_routeros

  # Optional inputs
  routeros_version  = try(values.routeros_version, "7.20.1")
  routeros_insecure = try(values.routeros_insecure, true)
}
