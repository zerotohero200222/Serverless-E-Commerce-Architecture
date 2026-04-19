##############################################################################
# terraform.tfvars — Default variable values
#
# Fill in `project_id` before running.
# Image tags are injected at runtime by Cloud Build — leave as "latest" here
# so local `terraform plan` runs don't fail.
##############################################################################

# ── Required — set this to your GCP project ID ───────────────────────────────
project_id = "eternal-bruin-489005-u2"

# ── Environment ───────────────────────────────────────────────────────────────
env      = "dev"
region   = "us-central1"
app_name = "ecommerce"

# ── Artifact Registry ─────────────────────────────────────────────────────────
ar_repository_id = "ecommerce-images"

# ── Image tags (overridden by Cloud Build substitutions at CI time) ───────────
product_image_tag   = "latest"
order_image_tag     = "latest"
inventory_image_tag = "latest"
frontend_image_tag  = "latest"

# ── Cloud Run ─────────────────────────────────────────────────────────────────
cloud_run_min_instances   = 0
cloud_run_max_instances   = 10
cloud_run_cpu             = "1"
cloud_run_memory          = "512Mi"
cloud_run_concurrency     = 80
cloud_run_timeout_seconds = 60
cloud_run_ingress         = "all"

# ── API Gateway ───────────────────────────────────────────────────────────────
api_gateway_deadline     = 60
api_gateway_display_name = "Ecommerce API Gateway"

# ── Load Balancer ─────────────────────────────────────────────────────────────
lb_load_balancing_scheme = "EXTERNAL_MANAGED"
lb_protocol              = "HTTP"
