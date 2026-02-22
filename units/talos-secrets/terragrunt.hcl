include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:kid/terragrunt-infra-catalog//modules/talos-secrets?ref=${values.version}"
}
