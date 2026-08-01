# DNS Configuration {{{

variable "dns_upstream_servers" {
  type = list(string)
}

variable "dns_static_records" {
  type = map(object({
    address  = string
    type     = optional(string, "A")
    comment  = optional(string)
    disabled = optional(bool, false)
  }))
  default = {}
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
