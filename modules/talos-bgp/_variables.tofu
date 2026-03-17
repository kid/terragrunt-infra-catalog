variable "cluster_name" {
  type        = string
  description = "Name of the Talos cluster"
  default     = "talos-cluster"
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
  description = "Map of Talos BGP peers keyed by peer name"
}

variable "bgp_local_asn" {
  type        = number
  description = "Local ASN for the RouterOS BGP instance"
  default     = 64512
}

variable "bgp_remote_asn" {
  type        = number
  description = "Remote ASN for the Talos/Cilium BGP peers"
  default     = 64513
}

variable "bgp_router_id" {
  type        = string
  description = "Router ID for BGP instance (typically router IP on the Talos VLAN)"
  default     = null
}
