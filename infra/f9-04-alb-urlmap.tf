##############################################################################
# f9-04-alb-urlmap.tf — URL Map (path-based routing rules)
#
# Routing rules:
#   /api/*  →  api-backend   (API Gateway → microservices)
#   /*      →  frontend-backend (default catch-all)
##############################################################################

resource "google_compute_url_map" "ecommerce" {
  project         = var.project_id
  name            = local.lb_url_map
  description     = "URL map for ${var.app_name} (${var.env})"
  default_service = google_compute_backend_service.frontend.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "ecommerce-paths"
  }

  path_matcher {
    name            = "ecommerce-paths"
    default_service = google_compute_backend_service.frontend.self_link

    path_rule {
      # Route all /api/* traffic to the API Gateway backend
      paths   = ["/api/*"]
      service = google_compute_backend_service.api.self_link
    }
  }

  depends_on = [
    google_compute_backend_service.frontend,
    google_compute_backend_service.api,
  ]
}
