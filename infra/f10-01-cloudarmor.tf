##############################################################################
# f10-01-cloudarmor.tf — Cloud Armor Security Policy
#
# Purpose:
#   Inject the x-api-key header into every request that passes through
#   the api-backend, so API Gateway can authenticate them.
#
# Security model:
#   ┌─────────┐     ┌──────────────┐   x-api-key injected   ┌─────────────┐
#   │ Client  │────▶│ Load Balancer│──────────────────────▶ │ API Gateway │
#   └─────────┘     └──────────────┘                         └─────────────┘
#                          │ Cloud Armor policy
#                          │ Rule 1000: allow all + inject header
#                          │ Default rule: allow (can tighten to deny later)
#
# Note: Cloud Armor request header injection is a GA feature as of 2024.
# The `request_headers_to_adds` block is supported in the google provider ≥ 5.x
##############################################################################

resource "google_compute_security_policy" "armor" {
  project     = var.project_id
  name        = local.armor_policy
  description = "Injects API Gateway key; future home for WAF / rate-limit rules."

  # ── Rule 1000: Allow all traffic + inject the API key header ─────────────────
  rule {
    priority    = 1000
    action      = "allow"
    description = "Allow all inbound traffic and inject x-api-key for API Gateway auth."

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }

    # Inject the API key as a request header before forwarding to the backend.
    # The key_string is sourced directly from the google_apikeys_key resource
    # so it is never hard-coded in this file.
    header_action {
      request_headers_to_adds {
        header_name  = "x-api-key"
        header_value = google_apikeys_key.gateway_key.key_string
        replace      = true
      }
    }
  }

  # ── Default rule (priority 2147483647): deny everything else ─────────────────
  # Keeping this as "allow" maintains backwards-compatible behaviour.
  # Change to "deny(403)" once you have confirmed rule 1000 covers all traffic.
  rule {
    priority    = 2147483647
    action      = "allow"
    description = "Default: allow remaining traffic (tighten in production)."

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  depends_on = [
    google_project_service.apis,
    google_apikeys_key.gateway_key,
  ]
}
