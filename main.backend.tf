resource "stackit_server" "backend" {
  count = var.backend_server_count

  project_id = var.project_id
  labels     = var.labels

  name = "backend${count.index}"

  boot_volume = {
    size                  = 25
    source_type           = "image"
    source_id             = "117e8764-41c2-405f-aece-b53aa08b28cc" # Ubuntu 24.04
    delete_on_termination = true
    performance_class     = "storage_premium_perf0"
  }

  machine_type      = "c1.1"
  availability_zone = "eu01-1"
  user_data         = data.cloudinit_config.backend.rendered
}

data "cloudinit_config" "backend" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = file("${path.module}/cloud-config.yaml")
  }
}

# Note: Currently, it is not possible to place the load balancer into multiple networks.
# Ideally, the listeners and backend servers would be in dedicated networks (frontend, backend).
#
# resource "stackit_network" "backend" {
#   project_id = var.project_id
#   labels     = var.labels

#   name               = "app"
#   ipv4_prefix_length = "29"
#   ipv4_nameservers   = var.ipv4_nameservers
# }

resource "stackit_network_interface" "backend" {
  count = var.backend_server_count

  project_id = var.project_id
  labels     = var.labels

  # Note: It is currently not possible to place the load balancer into multiple networks.
  # Therefore, a shared network is used for both backends and listeners.
  #
  # network_id         = stackit_network.backend.network_id

  network_id         = stackit_network.shared.network_id
  security_group_ids = [stackit_security_group.backend.security_group_id]
}

resource "stackit_server_network_interface_attach" "backend" {
  count = var.backend_server_count

  project_id           = var.project_id
  server_id            = stackit_server.backend[count.index].server_id
  network_interface_id = stackit_network_interface.backend[count.index].network_interface_id
}

resource "stackit_security_group" "backend" {
  project_id = var.project_id
  labels     = var.labels

  name     = "backend"
  stateful = true
}

resource "stackit_security_group_rule" "backend" {
  for_each = { for rule in [
    {
      name       = "ingress-ipv4"
      direction  = "ingress"
      ether_type = "IPv4"
    },
    {
      name       = "ingress-ipv6"
      direction  = "ingress"
      ether_type = "IPv6"
    }
  ] : rule.name => rule }

  project_id               = var.project_id
  security_group_id        = stackit_security_group.backend.security_group_id
  remote_security_group_id = stackit_security_group.frontend.security_group_id

  direction  = each.value.direction
  ether_type = each.value.ether_type

  port_range = {
    min = 80
    max = 80
  }

  protocol = {
    name = "tcp"
  }
}
