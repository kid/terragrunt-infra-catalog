terraform {
  required_version = ">= 1.10.0"

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.2.1"
    }
  }
}
