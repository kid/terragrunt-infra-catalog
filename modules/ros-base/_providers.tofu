provider "onepassword" {}

data "onepassword_item" "routeros" {
  vault = var.op_vault
  title = var.op_item_routeros
}

provider "routeros" {
  hosturl  = var.bootstrap ? "http://${var.routeros_endpoint}" : data.onepassword_item.routeros.url
  username = var.bootstrap ? "admin" : data.onepassword_item.routeros.username
  password = var.bootstrap ? "" : data.onepassword_item.routeros.password
  insecure = var.bootstrap ? true : var.routeros_insecure

  # Yes, I know system objects are only removed from the path
  suppress_syso_del_warn = true
}
