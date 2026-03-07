locals {
  nodes = {
    for name, node in var.nodes : name => {
      vm_name      = "${name}.${var.dhcp_dns_zone}"
      ip_address   = node.ip_address
      vm_id        = node.vm_id
      node_name    = coalesce(node.node_name, var.node_name)
      cpu_cores    = coalesce(node.cpu_cores, var.cpu_cores)
      memory       = coalesce(node.memory, var.memory)
      disk_size    = coalesce(node.disk_size, var.disk_size)
      datastore_id = coalesce(node.datastore_id, var.datastore_id)
      additional_disks = [
        for idx, disk in coalesce(try(node.additional_disks, null), var.additional_disks) : {
          size         = disk.size
          datastore_id = coalesce(try(disk.datastore_id, null), var.datastore_id)
          interface    = coalesce(try(disk.interface, null), "virtio${idx + 1}")
        }
      ]
      pci_devices = [
        for device in coalesce(try(node.pci_devices, null), var.pci_devices) : {
          device   = device.device
          id       = try(device.id, null)
          mapping  = try(device.mapping, null)
          mdev     = try(device.mdev, null)
          pcie     = try(device.pcie, null)
          rom_file = try(device.rom_file, null)
          rombar   = try(device.rombar, null)
          xvga     = try(device.xvga, null)
        }
      ]
    }
  }
}

# Generate MAC addresses with Terraform prefix (AC:1F:6B)
resource "macaddress" "nodes" {
  for_each = var.nodes
  prefix   = [172, 31, 107] # AC:1F:6B - Terraform prefix
}

# Generate Talos schematic for custom image configuration
data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = var.schematic_customizations.system_extensions
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
      }
      bootloader = "sd-boot"
    }
  })
}

# Get Talos image URLs from the factory
data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "nocloud"
  architecture  = "amd64"
}

# Download Talos image to Proxmox
resource "proxmox_virtual_environment_download_file" "talos_image" {
  node_name               = var.node_name
  content_type            = "iso"
  datastore_id            = var.talos_image_datastore
  url                     = data.talos_image_factory_urls.this.urls.disk_image
  file_name               = "talos-${var.talos_version}-${talos_image_factory_schematic.this.id}.img"
  decompression_algorithm = "zst"
  overwrite               = false
}

# Talos node VMs
resource "proxmox_virtual_environment_vm" "nodes" {
  for_each = local.nodes

  vm_id     = each.value.vm_id
  name      = each.value.vm_name
  node_name = each.value.node_name
  tags      = var.tags

  agent {
    enabled = true
  }

  stop_on_destroy = true
  scsi_hardware   = "virtio-scsi-single"

  bios = "ovmf"

  efi_disk {
    datastore_id = each.value.datastore_id
    type         = "4m"
  }

  cpu {
    cores = each.value.cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory
  }

  rng {
    source = "/dev/urandom"
  }

  disk {
    datastore_id = each.value.datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = each.value.disk_size
    iothread     = true
    discard      = "on"
  }

  dynamic "disk" {
    for_each = each.value.additional_disks

    content {
      datastore_id = disk.value.datastore_id
      interface    = disk.value.interface
      size         = disk.value.size
      iothread     = true
      discard      = "on"
    }
  }

  dynamic "hostpci" {
    for_each = each.value.pci_devices

    content {
      device   = hostpci.value.device
      id       = hostpci.value.id
      mapping  = hostpci.value.mapping
      mdev     = hostpci.value.mdev
      pcie     = hostpci.value.pcie
      rom_file = hostpci.value.rom_file
      rombar   = hostpci.value.rombar
      xvga     = hostpci.value.xvga
    }
  }

  network_device {
    bridge      = var.network_bridge
    vlan_id     = var.vlan_id
    mac_address = macaddress.nodes[each.key].address
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [disk[0].file_id]
  }
}

# DHCP static leases and DNS records on RouterOS
module "dhcp_leases" {
  for_each    = local.nodes
  source      = "../ros-dhcp-lease"
  dhcp_server = var.dhcp_server
  dns_zone    = var.dhcp_dns_zone

  lease = {
    name    = each.value.vm_name
    mac     = macaddress.nodes[each.key].address
    address = each.value.ip_address
    comment = each.value.vm_name
  }

  records = [
    {
      name    = each.value.vm_name
      address = each.value.ip_address
    },
    {
      name    = "api"
      address = each.value.ip_address
    },
  ]
}
