# Note: It is currently not possible to place the load balancer into multiple networks.
# Therefore, a shared network is used for both backends and listeners.
#
resource "stackit_network" "shared" {
  project_id = var.project_id

  name               = "shared"
  ipv4_prefix_length = "28"
  ipv4_nameservers   = var.ipv4_nameservers
}
