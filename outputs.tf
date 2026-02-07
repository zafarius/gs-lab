output "caddy_public_ip" {
  value       = gridscale_ipv4.caddy_ip.ip
  description = "The public IP address of the Caddy server"
}

output "nginx_public_ip" {
  value       = gridscale_ipv4.nginx_ip.ip
  description = "The public IP address of the Nginx server"
}

output "private_network_id" {
  value       = gridscale_network.private_net.id
  description = "The UUID of the private network"
}
