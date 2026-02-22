provider "onepassword" {}

provider "proxmox" {
  endpoint = local.proxmox_endpoint
  username = "${local.proxmox_username}@${local.proxmox_realm}"
  password = local.proxmox_password
  insecure = var.proxmox_insecure
}

provider "routeros" {
  hosturl  = strcontains(local.routeros_endpoint, "://") ? local.routeros_endpoint : data.external.endpoint["self"].result["endpoint"]
  insecure = coalesce(var.routeros_insecure, true)
  username = local.routeros_username
  password = local.routeros_password
}
