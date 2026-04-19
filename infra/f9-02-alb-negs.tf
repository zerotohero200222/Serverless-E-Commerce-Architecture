##############################################################################
# f9-02-alb-negs.tf — Serverless Network Endpoint Groups (NEGs)
#
# NEGs connect the global Load Balancer to serverless backends.
# Two NEGs are needed:
#   1. frontend-neg  → Cloud Run (frontend-service)
#   2. apigw-neg     → API Gateway (ecommerce-gateway)
#
# The API Gateway NEG requires the google-beta provider and the
# serverless_deployment block (not cloud_run block).
##############################################################################

# ── 1. Frontend Cloud Run NEG ─────────────────────────────────────────────────
resource "google_compute_region_network_endpoint_group" "frontend_neg" {
  provider              = google
  project               = var.project_id
  name                  = local.frontend_neg
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.frontend.name
  }

  depends_on = [
    google_project_service.apis,
    google_cloud_run_v2_service.frontend,
  ]
}

# ── 2. API Gateway NEG (beta resource) ────────────────────────────────────────
# Uses serverless_deployment instead of cloud_run because the backend is
# API Gateway, not Cloud Run directly.
resource "google_compute_region_network_endpoint_group" "apigw_neg" {
  provider              = google-beta
  project               = var.project_id
  name                  = local.api_gateway_neg
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  serverless_deployment {
    platform = "apigateway.googleapis.com"
    resource = google_api_gateway_gateway.ecommerce.gateway_id
  }

  depends_on = [
    google_project_service.apis,
    google_api_gateway_gateway.ecommerce,
  ]
}
