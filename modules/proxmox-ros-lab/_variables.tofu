variable "devices" {
  type = list(object({
    name = string
    type = string
    interfaces = list(object({
      name        = string
      type        = string # oob / port / wan / trunk
      mac_address = string
      ip_address  = optional(string)
      target      = optional(string)
    }))
  }))
}

variable "routeros_version" {
  type    = string
  default = "7.20.1"
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
