# vim: foldmethod=marker foldmarker={{{,}}}

# Device settings {{{

variable "hostname" {
  type        = string
  description = "The name to assign to this device"
}

variable "timezone" {
  type        = string
  default     = "Europe/Brussels"
  description = "The timezone to set on the device"
}

variable "ntp_servers" {
  type        = list(string)
  default     = ["time.cloudflare.com"]
  description = "List of NTP servers to use."
}

variable "ntp_server_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable NTP server functionality"
}

# }}}

# Certificate details {{{

variable "certificate_alt_names" {
  type        = list(string)
  description = "Alternative names for the device certificate."
}

variable "certificate_country" {
  type        = string
  default     = "BE"
  description = "Country code for the device certificate."
}

variable "certificate_locality" {
  type        = string
  default     = "BRU"
  description = "Locality for the device certificate."
}

variable "certificate_organization" {
  type        = string
  default     = "kidibox.net"
  description = "Organization for the device certificate."
}

variable "certificate_unit" {
  type        = string
  default     = "home"
  description = "Organizational unit for the device certificate."
}

# }}}

# Management settings {{{

variable "mgmt_interface_list" {
  type        = string
  description = "The management interface list name"
  default     = "all"
}

# }}}

# Bridge settings {{{

variable "bridge_name" {
  type        = string
  description = "Name of the main bridge interface"
}

variable "bridge_comment" {
  type        = string
  default     = ""
  description = "Comment for the bridge interface"
}

variable "bridge_mtu" {
  type        = number
  default     = null
  description = "MTU for the bridge interface"
}

# }}}

# Interface configuration {{{

variable "ethernet_interfaces" {
  type = map(object({
    name            = optional(string, "")
    comment         = optional(string, "")
    bridge_port     = optional(bool, true)
    mtu             = optional(number, 1500)
    l2mtu           = optional(number, 1518)
    interface_lists = optional(list(string), [])

    # VLAN configuration
    tagged   = optional(list(number), [])
    untagged = optional(number)
  }))
  default     = {}
  description = "Map of ethernet interfaces to configure"
}

# }}}

# VLAN Configuration {{{

variable "vlans" {
  type = map(object({
    name            = string
    vlan_id         = number
    mtu             = optional(number, 1500)
    interface_lists = optional(list(string), [])
  }))
  default = {}
}

# }}}

# IP Configuration {{{

variable "ip_addresses" {
  description = "Map of interface names to IP addresses"
  type        = map(string)
  default     = {}
}

variable "dhcp_clients" {
  description = "List of interfaces to create DHCP client on"
  type = list(object({
    interface    = string
    use_peer_dns = optional(bool, true)
    use_peer_ntp = optional(bool, true)
  }))
  default = []
}

# }}}

# DHCP Configuration {{{

variable "dhcp_servers" {
  type = map(object({
    cidr        = string
    domain      = optional(string)
    gateway     = optional(string)
    dhcp_pool   = optional(list(string))
    ntp_servers = optional(list(string))
    dns_servers = optional(list(string))
    static_leases = optional(list(object({
      name    = string
      mac     = string
      address = string
    })))
  }))
  default = {}
}

variable "dhcp_static_leases" {
  type = map(list(object({
    name    = string
    mac     = string
    address = string
  })))
  default = {}
}

# }}}

# 1Password / RouterOS credentials {{{

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

variable "bootstrap" {
  type        = bool
  default     = false
  description = "Connect using RouterOS factory-default credentials (admin / blank password) over plain HTTP instead of 1Password. Use only for the first apply against a freshly reset device, before its admin password has been set to match the 1Password item."
}

variable "routeros_endpoint" {
  type        = string
  nullable    = true
  default     = null
  description = "Bare host/IP of the MikroTik device. Only used when bootstrap = true."
}

variable "routeros_groups" {
  type = map(object({
    policies = list(string)
  }))
  description = "RouterOS user groups and their policies"
}

variable "routeros_users" {
  type = map(object({
    group         = optional(string, "full")
    comment       = optional(string)
    disabled      = optional(bool, false)
    ssh_keys      = optional(list(string), [])
    password_item = optional(string)
  }))
  description = "RouterOS local users, keyed by username. password_item, when set, is a 1Password item title (in op_vault) whose password is applied to this user; when unset (null), the user is created/updated but its password is left alone (never set, never overwritten) — e.g. admin, unless/until it has its own 1Password item to point at."
}

# }}}
