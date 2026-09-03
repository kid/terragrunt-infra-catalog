resource "routeros_zerotier" "this" {
  name = var.instance_name
  port = var.port
}

resource "routeros_zerotier_interface" "this" {
  instance = routeros_zerotier.this.name
  name     = var.interface_name
  network  = var.network_id

  allow_default = var.allow_default
  allow_global  = var.allow_global
  allow_managed = var.allow_managed
}

resource "routeros_interface_list_member" "this" {
  interface = routeros_zerotier_interface.this.name
  list      = var.interface_list
}
