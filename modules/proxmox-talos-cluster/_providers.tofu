provider "onepassword" {}

data "onepassword_item" "proxmox" {
  vault = var.op_vault
  title = var.op_item_proxmox
}

data "onepassword_item" "routeros" {
  vault = var.op_vault
  title = var.op_item_routeros
}

locals {
  op_proxmox = {
    for field in data.onepassword_item.proxmox.section[0].field : lower(field.label) => field.value
  }
  op_routeros = {
    for field in data.onepassword_item.routeros.section[0].field : lower(field.label) => field.value
  }
}

provider "proxmox" {
  endpoint = local.op_proxmox["endpoint"]
  username = "${local.op_proxmox["username"]}@${local.op_proxmox["realm"]}"
  password = local.op_proxmox["password"]
  insecure = var.proxmox_insecure
}

provider "routeros" {
  hosturl  = local.op_routeros["endpoint"]
  insecure = coalesce(var.routeros_insecure, true)
  username = local.op_routeros["username"]
  password = local.op_routeros["password"]
}
