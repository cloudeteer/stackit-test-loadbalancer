resource "stackit_loadbalancer" "frontend" {
  project_id = var.project_id

  name             = "frontend"
  external_address = stackit_public_ip.frontend.ip

  listeners = [
    {
      display_name = "tcp-80"
      port         = 80
      protocol     = "PROTOCOL_TCP"
      target_pool  = "backend"
    }
  ]

  networks = [

    # Note: Currently, it is not possible to place the load balancer into multiple networks.
    # Ideally, the listeners and backend servers would be in dedicated networks (frontend, backend).
    #
    # {
    #   network_id = stackit_network.frontend.network_id
    #   role       = "ROLE_LISTENERS"
    # },
    # {
    #   network_id = stackit_network.backend.network_id
    #   role       = "ROLE_TARGETS"
    # }

    {
      network_id = stackit_network.shared.network_id
      role       = "ROLE_LISTENERS_AND_TARGETS"
    }
  ]

  options = {
    private_network_only = false
  }

  target_pools = [
    {
      name        = "backend"
      target_port = 80

      targets = [
        for index, server in stackit_server.backend : {
          display_name = server.name
          ip           = stackit_network_interface.backend[index].ipv4
        }
      ]

      active_health_check = {
        healthy_threshold   = 10
        interval            = "3s"
        interval_jitter     = "3s"
        timeout             = "3s"
        unhealthy_threshold = 10
      }
    }
  ]
}

# Note: Currently, it is not possible to place the load balancer into multiple networks.
# Ideally, the listeners and backend servers would be in dedicated networks (frontend, backend).
#
# resource "stackit_network" "frontend" {
#   project_id = var.project_id
#   labels     = var.labels

#   name               = "app"
#   ipv4_prefix_length = "29"
#   ipv4_nameservers   = var.ipv4_nameservers
# }

# Note: The network interface assigned to the load balancer is not managed by Terraform;
# it is created transparently by the StackIT Cloud. This is not ideal because the stackit_public_ip.frontend
# resource will be modified outside of Terraform.
#
# resource "stackit_network_interface" "frontend" {
#   project_id = var.project_id
#   labels     = var.labels

#   # Note: It is currently not possible to place the load balancer into multiple networks.
#   # Therefore, a shared network is used for both backends and listeners.
#   #
#   # network_id         = stackit_network.backend.network_id

#   network_id = stackit_network.shared.network_id
# }

resource "stackit_public_ip" "frontend" {
  project_id = var.project_id
  labels     = var.labels

  # Note: the network interface id of this public IP is managed by StackIT Cloud.
  #
  # network_interface_id = stackit_network_interface.frontend.network_interface_id

  lifecycle {
    # Ignore changes to the network interface ID because this public IP
    # will be assigned to a StackIT managed network interface
    ignore_changes = [network_interface_id]
  }
}

resource "stackit_security_group" "frontend" {
  project_id = var.project_id
  labels     = var.labels

  name     = "frontend"
  stateful = true
}

resource "stackit_security_group_rule" "frontend" {
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

  project_id        = var.project_id
  security_group_id = stackit_security_group.frontend.security_group_id

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
