##############################################################################
# f9-03-alb-backends.tf — Global Backend Services
#
# Two backend services:
#   1. frontend-backend  → frontend NEG  (no Cloud Armor)
#   2. api-backend       → API GW NEG    (Cloud Armor injects x-api-key)
#
# Cloud Armor is attached ONLY to the api-backend so the security policy
# header injection happens on every request routed to API Gateway.
##############################################################################

# ── 1. Frontend Backend Service ───────────────────────────────────────────────
resource "google_compute_backend_service" "frontend" {
  provider                        = google
  project                         = var.project_id
  name                            = local.frontend_backend
  load_balancing_scheme           = var.lb_load_balancing_scheme
  protocol                        = var.lb_protocol
  port_name                       = "http"
  timeout_sec                     = 30
  enable_cdn                      = false

  backend {
    group = google_compute_region_network_endpoint_group.frontend_neg.id
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  depends_on = [
    google_project_service.apis,
    google_compute_region_network_endpoint_group.frontend_neg,
  ]
}

# ── 2. API Gateway Backend Service ────────────────────────────────────────────
# Cloud Armor security policy is attached here — it injects the x-api-key
# header on every request before it reaches the API Gateway.
resource "google_compute_backend_service" "api" {
  provider              = google
  project               = var.project_id
  name                  = local.api_backend
  load_balancing_scheme = var.lb_load_balancing_scheme
  protocol              = var.lb_protocol
  port_name             = "http"
  enable_cdn            = false

  backend {
    group = google_compute_region_network_endpoint_group.apigw_neg.id
  }

  # Attach Cloud Armor — injects x-api-key into every /api/* request
  security_policy = google_compute_security_policy.armor.self_link

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  depends_on = [
    google_project_service.apis,
    google_compute_region_network_endpoint_group.apigw_neg,
    google_compute_security_policy.armor,
  ]
}
