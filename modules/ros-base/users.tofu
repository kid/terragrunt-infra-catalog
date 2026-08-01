locals {
  usernames           = toset(keys(var.routeros_users))
  managed_usernames   = toset([for name, cfg in var.routeros_users : name if cfg.password_item != null])
  unmanaged_usernames = setsubtract(local.usernames, local.managed_usernames)
}

data "onepassword_item" "routeros_user" {
  for_each = { for name, cfg in var.routeros_users : name => cfg.password_item if cfg.password_item != null }
  vault    = var.op_vault
  title    = each.value
}

resource "routeros_system_user_group" "groups" {
  for_each = var.routeros_groups
  name     = each.key
  policy   = each.value.policies
}

resource "routeros_system_user" "users" {
  depends_on = [routeros_system_user_group.groups]
  for_each   = local.managed_usernames
  name       = each.key
  password   = data.onepassword_item.routeros_user[each.key].password
  group      = var.routeros_users[each.key].group
  comment    = var.routeros_users[each.key].comment
  disabled   = var.routeros_users[each.key].disabled

  lifecycle {
    prevent_destroy = true
  }
}

# Separate from the resource above because ignore_changes is static per
# resource, not per instance — can't ignore password only for users with no
# password_item within a single for_each.
resource "routeros_system_user" "unmanaged" {
  depends_on = [routeros_system_user_group.groups]
  for_each   = local.unmanaged_usernames
  name       = each.key
  group      = var.routeros_users[each.key].group
  comment    = var.routeros_users[each.key].comment
  disabled   = var.routeros_users[each.key].disabled

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [password]
  }
}

resource "routeros_system_user_sshkeys" "users_keys" {
  for_each = {
    for _, v in flatten([for name, user in var.routeros_users : [
      for idx, key in user.ssh_keys : { idx = idx, user = name, key = key }
    ]]) : "${v.user}_${v.idx}" => v
  }

  user = contains(local.managed_usernames, each.value.user) ? routeros_system_user.users[each.value.user].name : routeros_system_user.unmanaged[each.value.user].name
  key  = each.value.key
}

# admin pre-exists on every real device (factory default) and must be
# imported rather than created — regardless of which bucket it lands in.
import {
  for_each = contains(local.usernames, "admin") && var.routeros_users["admin"].password_item != null ? toset(["admin"]) : toset([])
  to       = routeros_system_user.users[each.key]
  id       = "name=admin"
}

import {
  for_each = contains(local.usernames, "admin") && var.routeros_users["admin"].password_item == null ? toset(["admin"]) : toset([])
  to       = routeros_system_user.unmanaged[each.key]
  id       = "name=admin"
}
