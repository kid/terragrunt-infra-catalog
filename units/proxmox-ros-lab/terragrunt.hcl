# Test trigger CI

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kid/terragrunt-infra-catalog//modules/proxmox-ros-lab?ref=${values.version}"
}

include "provider_proxmox" {
  path = "${get_repo_root()}/modules/_shared/provider-proxmox.hcl"
}

include "provider_routeros" {
  path = "${get_repo_root()}/_shared/provider-routeros.hcl"
}

inputs = {
  # Required inputs
  devices = values.devices

  # Optional inputs
  routeros_version = try(values.routeros_version, "7.20.1")
}
