##############################################################################
# f3-local-variables.tf — Derived naming locals
#
# Centralise all resource naming so every file references locals.* instead
# of duplicating string interpolation.  Change the pattern here and every
# resource picks it up automatically.
##############################################################################

locals {
  # ── Prefix applied to every resource name ──────────────────────────────────
  prefix = "${var.app_name}-${var.env}"

  # ── Artifact Registry image base path ──────────────────────────────────────
  ar_base = "${var.region}-docker.pkg.dev/${var.project_id}/${var.ar_repository_id}"

  # ── Fully-qualified image URIs (tag injected by Cloud Build) ───────────────
  product_image   = "${local.ar_base}/product-service:${var.product_image_tag}"
  order_image     = "${local.ar_base}/order-service:${var.order_image_tag}"
  inventory_image = "${local.ar_base}/inventory-service:${var.inventory_image_tag}"
  frontend_image  = "${local.ar_base}/frontend-service:${var.frontend_image_tag}"

  # ── Cloud Run service names ─────────────────────────────────────────────────
  product_service_name   = "${local.prefix}-product-service"
  order_service_name     = "${local.prefix}-order-service"
  inventory_service_name = "${local.prefix}-inventory-service"
  frontend_service_name  = "${local.prefix}-frontend-service"

  # ── API Gateway resource names ──────────────────────────────────────────────
  api_id          = "${local.prefix}-api"
  api_config_id   = "${local.prefix}-api-config"
  gateway_id      = "${local.prefix}-gateway"

  # ── Load Balancer resource names ────────────────────────────────────────────
  lb_ip_name        = "${local.prefix}-lb-ip"
  lb_url_map        = "${local.prefix}-url-map"
  lb_http_proxy     = "${local.prefix}-http-proxy"
  lb_fwd_rule       = "${local.prefix}-http-rule"

  # ── Backend service names ───────────────────────────────────────────────────
  frontend_backend = "${local.prefix}-frontend-backend"
  api_backend      = "${local.prefix}-api-backend"

  # ── NEG names ───────────────────────────────────────────────────────────────
  frontend_neg     = "${local.prefix}-frontend-neg"
  api_gateway_neg  = "${local.prefix}-apigw-neg"

  # ── Cloud Armor ─────────────────────────────────────────────────────────────
  armor_policy = "${local.prefix}-armor-policy"

  # ── Common labels applied to every resource ─────────────────────────────────
  common_labels = {
    app         = var.app_name
    env         = var.env
    managed_by  = "terraform"
    team        = "platform"
  }
}
