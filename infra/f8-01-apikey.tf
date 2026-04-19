##############################################################################
# f8-01-apikey.tf — GCP API Key used to authenticate requests to API Gateway
#
# Security flow:
#   Internet → LB → Cloud Armor (injects x-api-key) → API Gateway (validates)
#   Direct HTTPS requests to the Gateway hostname → 401 (no API key)
#
# The API key is stored in Terraform state.  For production, consider
# reading it from Secret Manager and rotating on a schedule.
##############################################################################

# ── API Key resource ──────────────────────────────────────────────────────────
resource "google_apikeys_key" "gateway_key" {
  project      = var.project_id
  name         = "${local.prefix}-gateway-key"
  display_name = "Ecommerce LB → API Gateway key (${var.env})"

  # NOTE: API key restrictions referencing apigateway.googleapis.com require
  # the managed service name (known only after gateway creation).
  # Restrictions are intentionally left open here and should be tightened
  # post-deploy once the gateway managed service name is known.
  # To tighten: add restrictions { api_targets { service = "<gateway-managed-service>" } }

  depends_on = [google_project_service.apis]
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "api_key_id" {
  description = "Resource name of the API key (not the secret string)."
  value       = google_apikeys_key.gateway_key.id
}

# NOTE: key_string is sensitive — Terraform marks it automatically.
# It is referenced directly in f10-01-cloudarmor.tf via:
#   google_apikeys_key.gateway_key.key_string
output "api_key_string" {
  description = "The raw API key string (sensitive — used by Cloud Armor)."
  value       = google_apikeys_key.gateway_key.key_string
  sensitive   = true
}
