##############################################################################
# f6-06-cloudrun-outputs.tf — Cloud Run service URLs and names
##############################################################################

output "product_service_url" {
  description = "HTTPS URL of the product Cloud Run service."
  value       = google_cloud_run_v2_service.product.uri
}

output "order_service_url" {
  description = "HTTPS URL of the order Cloud Run service."
  value       = google_cloud_run_v2_service.order.uri
}

output "inventory_service_url" {
  description = "HTTPS URL of the inventory Cloud Run service."
  value       = google_cloud_run_v2_service.inventory.uri
}

output "frontend_service_url" {
  description = "HTTPS URL of the frontend Cloud Run service."
  value       = google_cloud_run_v2_service.frontend.uri
}