resource "routeros_routing_bgp_instance" "talos" {
  name      = "${var.cluster_name}-bgp"
  as        = var.bgp_local_asn
  router_id = var.bgp_router_id
  vrf       = "main"
}

resource "routeros_routing_bgp_template" "talos" {
  name           = "${var.cluster_name}-peers"
  as             = var.bgp_local_asn
  routing_table  = "main"
  hold_time      = "1m30s"
  keepalive_time = "30s"
}

resource "routeros_routing_bgp_connection" "talos" {
  for_each = var.nodes

  name      = "${var.cluster_name}-${each.key}"
  as        = var.bgp_local_asn
  instance  = routeros_routing_bgp_instance.talos.name
  templates = [routeros_routing_bgp_template.talos.name]
  connect   = true
  listen    = true

  address_families = "ip"
  routing_table    = "main"

  local {
    role = "ebgp"
  }

  remote {
    address = each.value.ip_address
    as      = var.bgp_remote_asn
  }
}
