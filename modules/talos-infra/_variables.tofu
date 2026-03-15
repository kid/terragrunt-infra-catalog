variable "cluster_name" {
  type        = string
  description = "Name of the Talos cluster"
  default     = "talos-cluster"
}

variable "op_vault" {
  type        = string
  description = "1Password vault name or UUID for shared credentials"
}

variable "op_item_proxmox" {
  type        = string
  description = "1Password item title containing Proxmox credentials"
}

variable "op_item_routeros" {
  type        = string
  description = "1Password item title containing RouterOS credentials"
}

variable "nodes" {
  type = map(object({
    ip_address   = string
    vm_id        = optional(number)
    node_name    = optional(string)
    cpu_cores    = optional(number)
    memory       = optional(number)
    disk_size    = optional(number)
    datastore_id = optional(string)
    additional_disks = optional(list(object({
      size         = number
      datastore_id = optional(string)
      interface    = optional(string)
    })))
    pci_devices = optional(list(object({
      device   = optional(string)
      id       = optional(string)
      mapping  = optional(string)
      mdev     = optional(string)
      pcie     = optional(bool)
      rom_file = optional(string)
      rombar   = optional(bool)
      xvga     = optional(bool)
    })))
  }))
  description = "Map of Talos nodes to create. Key is the node name suffix."

  validation {
    condition = alltrue(flatten([
      for _, node in var.nodes : [
        for disk in coalesce(try(node.additional_disks, null), []) : try(disk.interface, null) == null || lower(disk.interface) != "virtio0"
      ]
    ]))
    error_message = "Node additional_disks interfaces cannot use virtio0 (reserved for the Talos boot disk)."
  }

  validation {
    condition = alltrue(flatten([
      for _, node in var.nodes : [
        for idx, device in coalesce(try(node.pci_devices, null), []) :
        ((try(device.id, null) == null) != (try(device.mapping, null) == null)) && can(regex("^hostpci[0-9]+$", coalesce(try(device.device, null), "hostpci${idx}")))
      ]
    ]))
    error_message = "Node pci_devices must set exactly one of id or mapping, and device must match hostpciN (e.g. hostpci0) when set."
  }

  validation {
    condition = alltrue([
      for _, node in var.nodes :
      length(coalesce(try(node.pci_devices, null), [])) <= 16
    ])
    error_message = "Node pci_devices supports up to 16 entries per VM."
  }

  validation {
    condition = alltrue([
      for _, node in var.nodes :
      length(distinct([
        for idx, device in coalesce(try(node.pci_devices, null), []) : coalesce(try(device.device, null), "hostpci${idx}")
      ])) == length(coalesce(try(node.pci_devices, null), []))
    ])
    error_message = "Node pci_devices device values must be unique per VM after default hostpciN assignment."
  }
}

variable "node_name" {
  type        = string
  description = "Default Proxmox node name to deploy VMs on"
  default     = "pve1"
}

variable "talos_version" {
  type        = string
  description = "Talos Linux version"
  default     = "v1.12.2"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.32.0"
}

variable "talos_image_datastore" {
  type        = string
  description = "Proxmox datastore to store the Talos image"
  default     = "local"
}

variable "cpu_cores" {
  type        = number
  description = "Default number of CPU cores for VMs"
  default     = 2
}

variable "memory" {
  type        = number
  description = "Default memory in MB for VMs"
  default     = 4096
}

variable "disk_size" {
  type        = number
  description = "Default disk size in GB for VMs"
  default     = 32
}

variable "datastore_id" {
  type        = string
  description = "Default Proxmox datastore ID for VM disks"
  default     = "local-zfs"
}

variable "additional_disks" {
  type = list(object({
    size         = number
    datastore_id = optional(string)
    interface    = optional(string)
  }))
  description = "Default additional data disks for Talos VMs. Interfaces default to virtio1+ per node."
  default     = []

  validation {
    condition     = alltrue([for disk in var.additional_disks : try(disk.interface, null) == null || lower(disk.interface) != "virtio0"])
    error_message = "additional_disks interfaces cannot use virtio0 (reserved for the Talos boot disk)."
  }
}

variable "pci_devices" {
  type = list(object({
    device   = optional(string)
    id       = optional(string)
    mapping  = optional(string)
    mdev     = optional(string)
    pcie     = optional(bool)
    rom_file = optional(string)
    rombar   = optional(bool)
    xvga     = optional(bool)
  }))
  description = "Default host PCI devices to pass through to Talos VMs. Each device must set exactly one of id or mapping."
  default     = []

  validation {
    condition = alltrue([
      for idx, device in var.pci_devices :
      ((try(device.id, null) == null) != (try(device.mapping, null) == null)) && can(regex("^hostpci[0-9]+$", coalesce(try(device.device, null), "hostpci${idx}")))
    ])
    error_message = "pci_devices must set exactly one of id or mapping, and device must match hostpciN (e.g. hostpci0) when set."
  }

  validation {
    condition     = length(var.pci_devices) <= 16
    error_message = "pci_devices supports up to 16 entries per VM."
  }

  validation {
    condition = length(distinct([
      for idx, device in var.pci_devices : coalesce(try(device.device, null), "hostpci${idx}")
    ])) == length(var.pci_devices)
    error_message = "pci_devices device values must be unique after default hostpciN assignment."
  }
}

variable "network_bridge" {
  type        = string
  description = "Network bridge for the VMs"
  default     = "vmbr0"
}

variable "proxmox_insecure" {
  type        = bool
  default     = false
  description = "Whether to skip TLS certificate verification when connecting to the Proxmox server"
}

variable "dhcp_server" {
  type        = string
  description = "RouterOS DHCP server name for static leases"
}

variable "dhcp_dns_zone" {
  type        = string
  description = "DNS zone to append to DHCP lease names"
  default     = null
}

variable "vlan_id" {
  type        = number
  description = "VLAN ID for the network interface"
  default     = null
}

variable "routeros_insecure" {
  type        = bool
  nullable    = true
  default     = null
  description = "Whether to skip TLS certificate verification when connecting to the MikroTik device"
}

variable "image_factory_schematic" {
  type        = map(any)
  description = "Talos Image Factory schematic object"
  default = {
    customization = {
      systemExtensions = {
        officialExtensions = ["qemu-guest-agent"]
      }
      bootloader = "sd-boot"
    }
  }
}

variable "tags" {
  type        = list(string)
  description = "Tags to apply to the VMs"
  default     = ["terraform", "talos"]
}

# BGP Configuration {{{

variable "bgp_enabled" {
  type        = bool
  description = "Enable BGP peering between RouterOS and Talos nodes"
  default     = false
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
  description = "Router ID for BGP instance (typically router's IP on the Talos VLAN)"
  default     = null
}

# }}}
