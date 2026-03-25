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

resource "google_compute_security_policy" "edge_security" {
  name        = "ecommerce-edge-policy"
  description = "Cloud Armor policy for routing and key injection"
  project     = var.project_id

  rule {
    action   = "allow"
    priority = "2147483647" # Default rule
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow and header injection"

    # Inject the API Key at the edge. The API Gateway will read this header.
    header_action {
      request_headers_to_adds {
        header_name  = "x-api-key"
        header_value = google_apikeys_key.gateway_key.key_string
      }
    }
  }
  depends_on = [google_project_service.enabled_apis]
}
