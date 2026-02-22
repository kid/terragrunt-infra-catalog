provider "onepassword" {}

data "onepassword_item" "proxmox" {
  vault = var.op_vault
  title = var.op_item_proxmox
}

data "onepassword_item" "routeros" {
  vault = var.op_vault
  title = var.op_item_routeros
}

# locals {
#   op_proxmox = {
#     for field in data.onepassword_item.proxmox.section[0].field : lower(field.label) => field.value
#   }
#   op_routeros = {
#     for field in data.onepassword_item.routeros.section[0].field : lower(field.label) => field.value
#   }
# }

provider "proxmox" {
  # endpoint = local.op_proxmox["endpoint"]
  endpoint = data.onepassword_item.proxmox.url
  username = data.onepassword_item.proxmox.username
  password = data.onepassword_item.proxmox.password
  insecure = false
}

provider "routeros" {
  hosturl  = data.onepassword_item.routeros.url
  username = data.onepassword_item.routeros.username
  password = data.onepassword_item.routeros.password
  insecure = true
}
