variable "bridge_name" {
  type        = string
  description = "Name of the main bridge interface"
}

variable "wan_interface" {
  type        = string
  description = "Name of the WAN interface"
}

variable "limit_rx" {
  type = string
}

variable "limit_tx" {
  type = string
}

variable "op_vault" {
  type        = string
  description = "1Password vault name or UUID for shared credentials"
}

variable "op_item_routeros" {
  type        = string
  description = "1Password item title containing RouterOS admin credentials (url, username, password)"
}

variable "routeros_insecure" {
  type        = bool
  nullable    = true
  default     = true
  description = "Whether to skip TLS certificate verification when connecting to the MikroTik device"
}
