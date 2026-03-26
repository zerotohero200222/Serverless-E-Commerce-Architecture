# Frontend Serverless NEG
resource "google_compute_region_network_endpoint_group" "frontend_neg" {
  name                  = "frontend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id

  cloud_run {
    service = google_cloud_run_v2_service.frontend.name
  }
}

# API Gateway Serverless NEG [5]
resource "google_compute_region_network_endpoint_group" "api_gateway_neg" {
  name                  = "api-gateway-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id
  provider              = google-beta

  serverless_deployment {
    platform = "apigateway.googleapis.com"
    resource = google_api_gateway_gateway.ecommerce_gateway.gateway_id
  }
}

# Backend Service for Frontend
resource "google_compute_backend_service" "frontend_backend" {
  name                  = "frontend-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  
  backend {
    group = google_compute_region_network_endpoint_group.frontend_neg.id
  }
}

# Backend Service for API Gateway (with Cloud Armor attached)
resource "google_compute_backend_service" "api_backend" {
  name                  = "api-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.edge_security.id
  
  backend {
    group = google_compute_region_network_endpoint_group.api_gateway_neg.id
  }
}

# URL Map for Path-Based Routing
resource "google_compute_url_map" "ecommerce_lb" {
  name            = "ecommerce-url-map"
  default_service = google_compute_backend_service.frontend_backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "api-matcher"
  }

  path_matcher {
    name            = "api-matcher"
    default_service = google_compute_backend_service.frontend_backend.id

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.api_backend.id
    }
  }
}

resource "google_compute_target_http_proxy" "ecommerce_proxy" {
  name    = "ecommerce-http-proxy"
  url_map = google_compute_url_map.ecommerce_lb.id
}

resource "google_compute_global_address" "ecommerce_ip" {
  name = "ecommerce-static-ip"
}

resource "google_compute_global_forwarding_rule" "ecommerce_rule" {
  name                  = "ecommerce-forwarding-rule"
  target                = google_compute_target_http_proxy.ecommerce_proxy.id
  port_range            = "80"
  ip_address            = google_compute_global_address.ecommerce_ip.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
