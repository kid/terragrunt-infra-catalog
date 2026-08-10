variable "cluster_name" {
  type        = string
  description = "Name of the cluster whose nodes this instance BGP-peers with"
  default     = "cluster"
}

variable "op_vault" {
  type        = string
  description = "1Password vault name or UUID for shared credentials"
}

variable "op_item_routeros" {
  type        = string
  description = "1Password item title containing RouterOS credentials"
}

variable "routeros_insecure" {
  type        = bool
  nullable    = true
  default     = true
  description = "Whether to skip TLS certificate verification when connecting to the MikroTik device"
}

variable "nodes" {
  type = map(object({
    ip_address = string
  }))
  description = "Map of BGP peers keyed by peer name"
}

variable "bgp_local_asn" {
  type        = number
  description = "Local ASN for the RouterOS BGP instance"
  default     = 64512
}

variable "bgp_remote_asn" {
  type        = number
  description = "Remote ASN shared by all entries in var.nodes"
  default     = 64513
}

variable "bgp_hold_time" {
  type        = string
  description = "BGP hold time for the peer template"
  default     = "1m30s"
}

variable "bgp_keepalive_time" {
  type        = string
  description = "BGP keepalive time for the peer template"
  default     = "30s"
}

variable "bgp_router_id" {
  type        = string
  description = "Router ID for BGP instance (typically router IP on the peered VLAN)"
  default     = null
}
