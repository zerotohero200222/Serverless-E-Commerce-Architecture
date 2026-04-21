##############################################################################
# f9-06-alb-outputs.tf — Load Balancer outputs
##############################################################################

output "load_balancer_ip" {
  description = "Public IP address of the External HTTP Load Balancer."
  value       = google_compute_global_address.lb_ip.address
}

output "load_balancer_url" {
  description = "Full HTTP URL to reach the application via the Load Balancer."
  value       = "http://${google_compute_global_address.lb_ip.address}"
}

output "load_balancer_api_url" {
  description = "Base URL for all API routes via the Load Balancer."
  value       = "http://${google_compute_global_address.lb_ip.address}/api"
}