resource "google_api_gateway_api" "ecommerce_api" {
  provider     = google-beta
  api_id       = "ecommerce-api"
  display_name = "E-Commerce Routing API"
  project      = var.project_id
  depends_on   = [google_project_service.enabled_apis]
}

resource "google_api_gateway_api_config" "ecommerce_config" {
  provider      = google-beta
  api           = google_api_gateway_api.ecommerce_api.api_id
  api_config_id = "ecommerce-config-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  project       = var.project_id

  openapi_documents {
    document {
      path = "openapi.yaml"
      contents = base64encode(templatefile("${path.module}/../config/openapi.yaml", {
        product_url   = google_cloud_run_v2_service.product.uri
        inventory_url = google_cloud_run_v2_service.inventory.uri
      }))
    }
  }

  gateway_config {
    backend_config {
      google_service_account = google_service_account.api_gateway_sa.email
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "ecommerce_gateway" {
  provider     = google-beta
  gateway_id   = "ecommerce-gateway"
  api_config   = google_api_gateway_api_config.ecommerce_config.id
  region       = var.region
  project      = var.project_id
  display_name = "E-Commerce Primary Gateway"
  depends_on   = [google_api_gateway_api_config.ecommerce_config]
}

resource "google_apikeys_key" "gateway_key" {
  name         = "internal-gateway-key"
  display_name = "Internal Key for API Gateway"
  project      = var.project_id

  restrictions {
    api_targets {
      service = google_api_gateway_api.ecommerce_api.managed_service
      methods = ["*"]
    }
  }
  depends_on = [google_project_service.enabled_apis]
}
