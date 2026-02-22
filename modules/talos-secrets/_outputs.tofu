output "talos_secrets" {
  description = "Talos secrets exported to 1Password"
  value       = local.secrets
  sensitive   = true
}

output "talosconfig_yaml" {
  description = "Talos client configuration YAML"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}
