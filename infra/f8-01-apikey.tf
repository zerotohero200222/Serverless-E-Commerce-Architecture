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

  # Restrict to API Gateway only (principle of least privilege)
  restrictions {
    api_targets {
      # The managed service name matches the pattern: <api_id>-<hash>.apigateway.googleapis.com
      # At creation time we cannot know the exact managed service name, so we
      # use a broad service target.  Tighten this post-deploy if desired.
      service = "apigateway.googleapis.com"
    }
  }

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
