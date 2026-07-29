##############################################################################
# f9-03-alb-backends.tf — Global Backend Services
#
# Two backend services:
#   1. frontend-backend  → frontend NEG
#   2. api-backend       → API GW NEG
#
# NOTE: Cloud Armor (and the x-api-key header it used to inject) has been
# removed. Traffic to /api/* now reaches API Gateway with no edge security
# policy attached to this backend. Add `security_policy = <policy>.self_link`
# back here if you reintroduce Cloud Armor or another WAF later.
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

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  depends_on = [
    google_project_service.apis,
    google_compute_region_network_endpoint_group.apigw_neg,
  ]
}

