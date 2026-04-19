##############################################################################
# f9-05-alb-frontend.tf — LB frontend: static IP + HTTP proxy + forwarding rule
#
# HTTP only for now (as agreed). To add HTTPS later:
#   1. Create google_compute_managed_ssl_certificate
#   2. Create google_compute_target_https_proxy
#   3. Add a second forwarding rule on port 443
#   4. Add an HTTP→HTTPS redirect url_map on port 80
##############################################################################

# ── 1. Reserve a global static IP ─────────────────────────────────────────────
resource "google_compute_global_address" "lb_ip" {
  project      = var.project_id
  name         = local.lb_ip_name
  ip_version   = "IPV4"
  address_type = "EXTERNAL"

  depends_on = [google_project_service.apis]
}

# ── 2. Target HTTP Proxy ───────────────────────────────────────────────────────
resource "google_compute_target_http_proxy" "ecommerce" {
  project  = var.project_id
  name     = local.lb_http_proxy
  url_map  = google_compute_url_map.ecommerce.self_link

  depends_on = [google_compute_url_map.ecommerce]
}

# ── 3. Global Forwarding Rule (port 80) ───────────────────────────────────────
resource "google_compute_global_forwarding_rule" "http" {
  project               = var.project_id
  name                  = local.lb_fwd_rule
  load_balancing_scheme = var.lb_load_balancing_scheme
  ip_address            = google_compute_global_address.lb_ip.address
  target                = google_compute_target_http_proxy.ecommerce.self_link
  port_range            = "80"

  depends_on = [
    google_compute_global_address.lb_ip,
    google_compute_target_http_proxy.ecommerce,
  ]
}
