output "instance_name" {
  description = "BGP instance name when enabled"
  value       = var.bgp_enabled ? routeros_routing_bgp_instance.talos[0].name : null
}

output "template_name" {
  description = "BGP template name when enabled"
  value       = var.bgp_enabled ? routeros_routing_bgp_template.talos[0].name : null
}

output "connection_names" {
  description = "BGP connection names keyed by peer"
  value       = { for name, connection in routeros_routing_bgp_connection.talos : name => connection.name }
}

output "connection_ids" {
  description = "BGP connection IDs keyed by peer"
  value       = { for name, connection in routeros_routing_bgp_connection.talos : name => connection.id }
}
