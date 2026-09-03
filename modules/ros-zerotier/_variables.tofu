# ZeroTier Configuration {{{

variable "instance_name" {
  type        = string
  description = "Name of the local ZeroTier instance (node identity)"
}

variable "interface_name" {
  type        = string
  description = "Name of the ZeroTier interface created for the joined network"
}

variable "network_id" {
  type        = string
  description = "16-hex-digit ZeroTier network ID to join"
}

variable "port" {
  type        = number
  default     = 9993
  description = "UDP port the local ZeroTier instance listens on"
}

variable "allow_default" {
  type        = bool
  default     = false
  description = "Whether to accept a pushed default route from the ZeroTier network (full-tunnel). false = split-tunnel."
}

variable "allow_global" {
  type        = bool
  default     = false
  description = "Whether to allow ZeroTier-pushed routes that overlap public IP space"
}

variable "allow_managed" {
  type        = bool
  default     = true
  description = "Whether to accept IP address/route assignments managed by the network controller"
}

variable "interface_list" {
  type        = string
  description = "RouterOS interface list the resulting ZeroTier interface is added to"
}

# }}}

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
