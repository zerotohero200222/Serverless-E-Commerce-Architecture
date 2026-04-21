##############################################################################
# f7-03-apigateway-outputs.tf — API Gateway outputs
##############################################################################

output "api_gateway_id" {
  description = "Resource ID of the API Gateway."
  value       = google_api_gateway_gateway.ecommerce.gateway_id
}

output "api_gateway_default_hostname" {
  description = "Default HTTPS hostname of the API Gateway (without scheme)."
  value       = google_api_gateway_gateway.ecommerce.default_hostname
}

output "api_gateway_url" {
  description = "Full HTTPS base URL of the API Gateway."
  value       = "https://${google_api_gateway_gateway.ecommerce.default_hostname}"
}
