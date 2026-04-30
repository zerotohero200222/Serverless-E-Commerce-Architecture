##############################################################################
# f6-05-cloudrun-frontend.tf — Frontend service on Cloud Run
# allUsers invoker IAM managed via gcloud in cloudbuild.yaml
##############################################################################

resource "google_cloud_run_v2_service" "frontend" {
  project  = var.project_id
  name     = local.frontend_service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"
  labels   = local.common_labels

  template {
    labels = local.common_labels
    scaling {
      min_instance_count = var.cloud_run_min_instances
      max_instance_count = var.cloud_run_max_instances
    }
    containers {
      name  = "frontend-service"
      image = local.frontend_image
      resources {
        limits   = { cpu = var.cloud_run_cpu, memory = var.cloud_run_memory }
        cpu_idle = true
      }
      ports { container_port = 8080 }
      env { name = "ENV" value = var.env }
    }
    timeout = "${var.cloud_run_timeout_seconds}s"
  }
  depends_on = [google_project_service.apis, google_artifact_registry_repository.ecommerce]
}
