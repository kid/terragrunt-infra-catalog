# vim: foldmethod=marker foldmarker={{{,}}}

# Interface lists {{{

variable "mgmt_interface_list" {
  type        = string
  description = "The management interface list"
}

variable "wan_interface_list" {
  type = string
}

# }}}

# VLAN Configuration {{{

variable "vlans" {
  type = map(object({
    name    = string
    vlan_id = number
    address = string
  }))
  default = {}
}

variable "vlans_input_rules" {
  type = map(list(object({
    comment            = string
    action             = string
    disabled           = optional(bool)
    protocol           = optional(string)
    out_interface      = optional(string)
    out_interface_list = optional(string)
    src_address        = optional(string)
    src_address_list   = optional(string)
    src_port           = optional(string)
    dst_address        = optional(string)
    dst_address_list   = optional(string)
    dst_port           = optional(string)
  })))
  default = {}
}

variable "vlans_forward_rules" {
  type = map(list(object({
    comment            = string
    action             = string
    disabled           = optional(bool)
    protocol           = optional(string)
    out_interface      = optional(string)
    out_interface_list = optional(string)
    src_address        = optional(string)
    src_address_list   = optional(string)
    src_port           = optional(string)
    dst_address        = optional(string)
    dst_address_list   = optional(string)
    dst_port           = optional(string)
  })))
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
