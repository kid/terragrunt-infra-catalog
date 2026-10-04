resource "routeros_interface_ethernet" "ethernet" {
  for_each = var.ethernet_interfaces

  factory_name = each.key
  name         = coalesce(each.value.name, each.key)
  comment      = each.value.comment
  mtu          = each.value.mtu
  l2mtu        = each.value.l2mtu
}
