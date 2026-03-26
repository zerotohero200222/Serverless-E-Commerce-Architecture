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

    header_action {
      request_headers_to_adds {
        header_name  = "x-api-key"
        header_value = google_apikeys_key.gateway_key.key_string
      }
    }
  }
  depends_on = [google_project_service.enabled_apis]
}
