include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kid/terragrunt-infra-catalog//modules/ros-capsman?ref=${values.version}"
}

include "provider_routeros" {
  path = "${get_repo_root()}/_shared/provider-routeros.hcl"
}
