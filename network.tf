resource "gridscale_network" "private_net" {
  name       = "private-network"
  l2security = false
  dhcp_active = false
}
