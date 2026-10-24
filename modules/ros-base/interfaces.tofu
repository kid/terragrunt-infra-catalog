locals {
  # The bridge's L2MTU is the lowest of its ports, so bridge ports default to
  # their hardware maximum; otherwise one port left at the default caps every
  # VLAN on the bridge ("MTU > L2MTU").
  ethernet_max_l2mtu = {
    for _, ifce in data.routeros_interfaces.self.interfaces :
    ifce.default_name => ifce.max_l2mtu
    if ifce.type == "ether"
  }
}

resource "routeros_interface_ethernet" "ethernet" {
  for_each = var.ethernet_interfaces

  factory_name = each.key
  name         = coalesce(each.value.name, each.key)
  comment      = each.value.comment
  mtu          = each.value.mtu
  l2mtu = each.value.l2mtu != null ? each.value.l2mtu : (
    each.value.bridge_port ? local.ethernet_max_l2mtu[each.key] : null
  )
}
