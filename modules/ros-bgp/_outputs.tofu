output "instance_name" {
  description = "BGP instance name"
  value       = routeros_routing_bgp_instance.bgp.name
}

output "template_name" {
  description = "BGP template name"
  value       = routeros_routing_bgp_template.bgp.name
}

output "connection_names" {
  description = "BGP connection names keyed by peer"
  value       = { for name, connection in routeros_routing_bgp_connection.bgp : name => connection.name }
}

output "connection_ids" {
  description = "BGP connection IDs keyed by peer"
  value       = { for name, connection in routeros_routing_bgp_connection.bgp : name => connection.id }
}
