terraform {
  required_version = "~> 1.0"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "0.44.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.6"
    }
  }
}
