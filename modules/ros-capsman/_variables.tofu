variable "capsman_interfaces" {
  description = "List of interfaces (lists) on which CAPsMAN will listen for CAP connections."
  type        = list(string)
}

variable "bridge_name" {
  description = "Name of the bridge defined on the CAP devices."
  type        = string
}

variable "passphrase_groups" {
  description = "Map of passphrase groups for different SSIDs and VLANs."
  type = map(object({
    vlan_id  = number
    isolated = optional(bool, false)
  }))
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

variable "op_item_wifi" {
  type        = string
  description = "1Password item title containing the WiFi SSID (field \"ssid\") and one field per passphrase_groups key holding that group's passphrase"
}
