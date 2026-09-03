resource "zerotier_network" "this" {
  name    = var.network_name
  private = true

  assign_ipv4 {
    zerotier = true
  }

  dynamic "assignment_pool" {
    for_each = [var.assignment_pool]
    content {
      start = assignment_pool.value.start
      end   = assignment_pool.value.end
    }
  }

  dynamic "route" {
    for_each = var.routes
    content {
      target = route.value.target
      via    = route.value.via
    }
  }
}

resource "zerotier_member" "router" {
  name           = "rb5009"
  member_id      = var.router_member_id
  network_id     = zerotier_network.this.id
  authorized     = true
  ip_assignments = [var.router_ip]
}
