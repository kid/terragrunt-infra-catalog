locals {
  usernames = toset(keys(var.routeros_users))
}

# The admin item is the same one used for the provider connection (data.onepassword_item.routeros);
# every other user gets its own 1Password item so passwords can be rotated independently.
data "onepassword_item" "routeros_user" {
  for_each = setsubtract(local.usernames, ["admin"])
  vault    = var.op_vault
  title    = "${upper(var.hostname)} - user - ${each.key}"
}

locals {
  user_passwords = merge(
    { admin = data.onepassword_item.routeros.password },
    { for name, item in data.onepassword_item.routeros_user : name => item.password }
  )
}

resource "routeros_system_user_group" "groups" {
  for_each = var.routeros_groups
  name     = each.key
  policy   = each.value.policies
}

resource "routeros_system_user" "users" {
  depends_on = [routeros_system_user_group.groups]
  for_each   = local.usernames
  name       = each.key
  password   = local.user_passwords[each.key]
  group      = var.routeros_users[each.key].group
  comment    = var.routeros_users[each.key].comment
  disabled   = var.routeros_users[each.key].disabled

  lifecycle {
    prevent_destroy = true
  }
}

resource "routeros_system_user_sshkeys" "users_keys" {
  for_each = {
    for _, v in flatten([for name, user in var.routeros_users : [
      for idx, key in user.ssh_keys : { idx = idx, user = name, key = key }
    ]]) : "${v.user}_${v.idx}" => v
  }

  user = routeros_system_user.users[each.value.user].name
  key  = each.value.key
}

import {
  for_each = setintersection(local.usernames, ["admin"])
  to       = routeros_system_user.users[each.key]
  id       = "name=admin"
}
