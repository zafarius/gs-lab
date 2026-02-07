terraform {
  required_providers {
    gridscale = {
      source  = "gridscale/gridscale"
      version = "~> 2.1"
    }
  }
}

provider "gridscale" {
  uuid  = var.gridscale_uuid
  token = var.gridscale_token
}
