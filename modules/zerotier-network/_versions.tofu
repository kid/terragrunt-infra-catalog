terraform {
  required_version = ">= 1.10"

  required_providers {
    zerotier = {
      source  = "zerotier/zerotier"
      version = "1.6.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
  }
}
