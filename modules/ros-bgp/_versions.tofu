terraform {
  required_version = ">= 1.8.0"

  required_providers {
    # terraform-routeros/routeros unconditionally sends `add-path-out` on
    # /routing/bgp/{template,connection} creates (a schema default, always
    # serialized regardless of whether it's set) — RouterOS removed that
    # parameter in a recent release, so every apply 400s with "unknown
    # parameter add-path-out"
    # (https://github.com/terraform-routeros/terraform-provider-routeros/issues/959,
    # open, no fix). ebogdum/routeros is a from-scratch, terraform-plugin-
    # framework-based provider validated against live RouterOS 7.x devices
    # (so its schema doesn't carry stale/removed fields), used here at
    # least for BGP; other ros-* modules may follow.
    # Not on registry.opentofu.org (OpenTofu's default) — explicit
    # registry.terraform.io host needed, since this repo uses OpenTofu.
    routeros = {
      source  = "registry.terraform.io/ebogdum/routeros"
      version = "~> 4.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
  }
}
