resource "google_cloud_run_v2_service" "inventory" {
  project  = var.project_id
  name     = local.inventory_service_name
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
      name  = "inventory-service"
      image = local.inventory_image
      resources {
        limits   = { cpu = var.cloud_run_cpu, memory = var.cloud_run_memory }
        cpu_idle = true
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
        value = "inventory-service"
      }
    }
    timeout = "${var.cloud_run_timeout_seconds}s"
  }
  depends_on = [google_project_service.apis, google_artifact_registry_repository.ecommerce]
}
