output "identity_public" {
  description = "This node's public ZeroTier identity (10-hex device/member ID) — needed once, by hand, to authorize it in ZeroTier Central"
  value       = routeros_zerotier.this.identity_public
}
