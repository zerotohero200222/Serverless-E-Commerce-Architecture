##############################################################################
# f6-02-cloudrun-product.tf — Product microservice on Cloud Run
# allUsers invoker IAM managed via gcloud in cloudbuild.yaml
##############################################################################

resource "google_cloud_run_v2_service" "product" {
  project  = var.project_id
  name     = local.product_service_name
  location = var.region
  ingress  = var.cloud_run_ingress
  labels   = local.common_labels

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
        limits   = { cpu = var.cloud_run_cpu, memory = var.cloud_run_memory }
        cpu_idle = true
      }
      ports { container_port = 8080 }
      env { name = "ENV"          value = var.env }
      env { name = "SERVICE_NAME" value = "product-service" }
    }
    timeout = "${var.cloud_run_timeout_seconds}s"
  }
  depends_on = [google_project_service.apis, google_artifact_registry_repository.ecommerce]
}
