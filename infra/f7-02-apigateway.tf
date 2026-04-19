##############################################################################
# f7-02-apigateway.tf — API Gateway: API + Config + Gateway
#
# The OpenAPI spec is rendered via templatefile() so the Cloud Run URLs
# (which are known only after Terraform creates the Cloud Run services)
# are injected at plan time — no shell variable substitution needed.
##############################################################################

# ── 1. API resource (logical grouping) ────────────────────────────────────────
resource "google_api_gateway_api" "ecommerce" {
  provider     = google-beta
  project      = var.project_id
  api_id       = local.api_id
  display_name = var.api_gateway_display_name

  depends_on = [google_project_service.apis]
}

# ── 2. API Config (versioned OpenAPI spec) ────────────────────────────────────
# templatefile() renders the OpenAPI YAML, substituting the real Cloud Run
# service URLs and other parameters.  A new config is created whenever the
# spec changes; the gateway is then updated to point at the latest config.
resource "google_api_gateway_api_config" "ecommerce" {
  provider      = google-beta
  project       = var.project_id
  api           = google_api_gateway_api.ecommerce.api_id
  api_config_id = local.api_config_id
  display_name  = "${var.app_name} API config (${var.env})"

  openapi_documents {
    document {
      path = "openapi.yaml"
      contents = base64encode(templatefile("${path.module}/templates/openapi.yaml.tpl", {
        api_id        = local.api_id
        product_url   = google_cloud_run_v2_service.product.uri
        order_url     = google_cloud_run_v2_service.order.uri
        inventory_url = google_cloud_run_v2_service.inventory.uri
        deadline      = tostring(var.api_gateway_deadline)
      }))
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_api_gateway_api.ecommerce,
    google_cloud_run_v2_service.product,
    google_cloud_run_v2_service.order,
    google_cloud_run_v2_service.inventory,
  ]
}

# ── 3. Gateway (regional deployment of the config) ────────────────────────────
resource "google_api_gateway_gateway" "ecommerce" {
  provider     = google-beta
  project      = var.project_id
  region       = var.region
  gateway_id   = local.gateway_id
  api_config   = google_api_gateway_api_config.ecommerce.id
  display_name = var.api_gateway_display_name

  depends_on = [google_api_gateway_api_config.ecommerce]
}
