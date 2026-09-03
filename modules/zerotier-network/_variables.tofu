# ZeroTier Central Configuration {{{

variable "network_name" {
  type        = string
  description = "Name of the ZeroTier network in ZeroTier Central"
}

variable "assignment_pool" {
  type = object({
    start = string
    end   = string
  })
  description = "IPv4 address range ZeroTier Central hands out to authorized members"
}

variable "routes" {
  type = list(object({
    target = string
    via    = optional(string)
  }))
  default     = []
  description = "Routes pushed to every authorized member (e.g. home LAN subnets, routed via the router's ZeroTier-managed IP)"
}

variable "router_member_id" {
  type        = string
  description = "The RouterOS node's public ZeroTier identity (10-hex device ID) — authorized as the network's subnet router"
}

variable "router_ip" {
  type        = string
  description = "Fixed IPv4 address assigned to the router member, matching the address routes are routed via"
}

# }}}

variable "op_vault" {
  type        = string
  description = "1Password vault name or UUID for shared credentials"
}

variable "op_item_zerotier_central" {
  type        = string
  description = "1Password item title containing the ZeroTier Central API token (in the credential field)"
}
