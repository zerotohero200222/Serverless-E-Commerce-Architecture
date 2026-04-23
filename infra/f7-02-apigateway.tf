##############################################################################
# f7-02-apigateway.tf — API Gateway: API + Config + Gateway
#
# API Gateway provisioning is slow (3-8 min per resource). Explicit timeouts
# are set on all three resources so Terraform waits long enough instead of
# timing out with a spurious error.
##############################################################################

# ── 1. API resource ───────────────────────────────────────────────────────────
resource "google_api_gateway_api" "ecommerce" {
  provider     = google-beta
  project      = var.project_id
  api_id       = local.api_id
  display_name = var.api_gateway_display_name

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }

  depends_on = [google_project_service.apis]
}

# ── 2. API Config ─────────────────────────────────────────────────────────────
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

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
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

# ── 3. Gateway ────────────────────────────────────────────────────────────────
resource "google_api_gateway_gateway" "ecommerce" {
  provider     = google-beta
  project      = var.project_id
  region       = var.region
  gateway_id   = local.gateway_id
  api_config   = google_api_gateway_api_config.ecommerce.id
  display_name = var.api_gateway_display_name

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }

  depends_on = [google_api_gateway_api_config.ecommerce]
}
