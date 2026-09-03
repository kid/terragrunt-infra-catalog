provider "onepassword" {}

data "onepassword_item" "zerotier_central" {
  vault = var.op_vault
  title = var.op_item_zerotier_central
}

provider "zerotier" {
  zerotier_central_token = data.onepassword_item.zerotier_central.credential
}
