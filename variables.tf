variable "gridscale_uuid" {
  description = "The UUID of the Gridscale project"
  type        = string
}

variable "gridscale_token" {
  description = "The API token for Gridscale"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Public SSH key to inject into VMs"
  type        = string
}


variable "public_network_uuid" {
  description = "UUID of the Gridscale public network in your location (attach server to this to get internet access)"
  type        = string
  default     = "45fe71e4-e987-4bf5-91ce-50d0876ddd9d"
}

variable "caddy_private_ip" {
  description = "Private IP address for the Caddy server"
  type        = string
  default     = "192.168.10.1/24"
}

variable "nginx_private_ip" {
  description = "Private IP address for the Nginx server"
  type        = string
  default     = "192.168.10.2/24"
}

