# WiFi SSID + per-passphrase-group passphrases live as custom fields on a single
# 1Password item (one field per passphrase group, keyed by var.passphrase_groups' keys,
# plus a "ssid" field).
data "onepassword_item" "wifi" {
  vault = var.op_vault
  title = var.op_item_wifi
}

locals {
  wifi_fields = {
    for field in flatten([for section in data.onepassword_item.wifi.section : section.field]) :
    field.label => field.value
  }
  wifi_ssid = local.wifi_fields["ssid"]
}
