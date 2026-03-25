output "load_balancer_ip" {
  description = "The global IP address of the External Load Balancer"
  value       = google_compute_global_address.ecommerce_ip.address
}

output "api_gateway_url" {
  description = "The default hostname of the managed API Gateway"
  value       = google_api_gateway_gateway.ecommerce_gateway.default_hostname
}

output "api_key_id" {
  description = "The ID of the generated API Key for gateway access"
  value       = google_apikeys_key.gateway_key.id
}
