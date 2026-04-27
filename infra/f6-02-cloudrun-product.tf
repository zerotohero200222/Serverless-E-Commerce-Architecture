##############################################################################
# f6-02-cloudrun-product.tf — Product microservice on Cloud Run
##############################################################################

resource "google_cloud_run_v2_service" "product" {
  project  = var.project_id
  name     = local.product_service_name
  location = var.region

  # Restrict ingress so this service is only reachable via API Gateway / LB
  ingress = var.cloud_run_ingress

  labels = local.common_labels

  template {
    labels = local.common_labels

    scaling {
      min_instance_count = var.cloud_run_min_instances
      max_instance_count = var.cloud_run_max_instances
    }

    containers {
      name  = "product-service"
      image = local.product_image

      resources {
        limits = {
          cpu    = var.cloud_run_cpu
          memory = var.cloud_run_memory
        }
        cpu_idle = true # only consume CPU during request processing
      }

      ports {
        container_port = 8080
      }
      env {
        name  = "ENV"
        value = var.env
      }
      env {
        name  = "SERVICE_NAME"
        value = "product-service"
      }
    }

    timeout = "${var.cloud_run_timeout_seconds}s"
  }

  depends_on = [
    google_project_service.apis,
    google_artifact_registry_repository.ecommerce,
  ]
}

# ── Allow unauthenticated access (API Gateway authenticates instead) ──────────
resource "google_cloud_run_v2_service_iam_member" "product_public" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.product.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
