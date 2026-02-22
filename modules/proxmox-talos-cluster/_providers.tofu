provider "onepassword" {}

data "onepassword_item" "proxmox" {
  vault = var.op_vault
  title = var.op_item_proxmox
}

data "onepassword_item" "routeros" {
  vault = var.op_vault
  title = var.op_item_routeros
}

provider "proxmox" {
  endpoint = data.onepassword_item.proxmox.url
  username = "${data.onepassword_item.proxmox.username}@${data.onepassword_item.proxmox.fields.realm}"
  password = data.onepassword_item.proxmox.password
  insecure = false
}

provider "routeros" {
  hosturl  = data.onepassword_item.routeros.url
  username = data.onepassword_item.routeros.username
  password = data.onepassword_item.routeros.password
  insecure = true
}
