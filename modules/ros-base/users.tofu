locals {
  usernames = toset(keys(var.routeros_users))
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
  for_each   = local.usernames
  name       = each.key
  # password is Optional but not Computed in the provider schema, so null
  # here means Terraform actively sets/keeps it blank, not "leave as-is".
  password = try(data.onepassword_item.routeros_user[each.key].password, null)
  group    = var.routeros_users[each.key].group
  comment  = var.routeros_users[each.key].comment
  disabled = var.routeros_users[each.key].disabled

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
