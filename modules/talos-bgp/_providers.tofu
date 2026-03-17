provider "onepassword" {}

data "onepassword_item" "routeros" {
  vault = var.op_vault
  title = var.op_item_routeros
}

provider "routeros" {
  hosturl  = data.onepassword_item.routeros.url
  username = data.onepassword_item.routeros.username
  password = data.onepassword_item.routeros.password
  insecure = var.routeros_insecure
}
