variable "cluster_name" {
  type        = string
  description = "Name of the Talos cluster"
  default     = "talos-cluster"
}

variable "talos_version" {
  type        = string
  description = "Talos version for generated secrets"
  default     = "v1.12.2"
}

variable "talos_endpoints" {
  type        = list(string)
  description = "Talos API endpoints to embed in the talosconfig"
  default     = []
}

variable "talos_nodes" {
  type        = list(string)
  description = "Talos nodes to embed in the talosconfig"
  default     = []
}

variable "op_vault" {
  type        = string
  description = "1Password vault name or UUID"
  default     = "home-ops"
}

variable "op_item" {
  type        = string
  description = "1Password item title"
  default     = "talos"
}

variable "op_account" {
  type        = string
  description = "1Password account name or ID (required when using the desktop app integration)"
  default     = null
}

variable "op_service_account_token" {
  type        = string
  sensitive   = true
  description = "1Password service account token (preferred for headless environments)"
  default     = null
}

variable "op_connect_url" {
  type        = string
  description = "1Password Connect server URL"
  default     = null
}

variable "op_connect_token" {
  type        = string
  sensitive   = true
  description = "1Password Connect server token"
  default     = null
}
