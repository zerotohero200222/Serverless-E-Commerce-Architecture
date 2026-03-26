# Service Account strictly used by API Gateway to authenticate against Cloud Run [3]
resource "google_service_account" "api_gateway_sa" {
  account_id   = "api-gateway-invoker"
  display_name = "API Gateway Service Account"
  project      = var.project_id
  depends_on   = [google_project_service.enabled_apis]
}

# Frontend Service
resource "google_cloud_run_v2_service" "frontend" {
  name     = "frontend-service"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = var.frontend_image
      ports {
        container_port = 8080
      }
    }
  }
  depends_on = [google_project_service.enabled_apis]
}

resource "google_cloud_run_service_iam_member" "frontend_public" {
  location = google_cloud_run_v2_service.frontend.location
  project  = google_cloud_run_v2_service.frontend.project
  service  = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Product Service
resource "google_cloud_run_v2_service" "product" {
  name     = "product-service"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = var.product_image
    }
  }
  depends_on = [google_project_service.enabled_apis]
}

# Inventory Service
resource "google_cloud_run_v2_service" "inventory" {
  name     = "inventory-service"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = var.inventory_image
    }
  }
  depends_on = [google_project_service.enabled_apis]
}

# Authorize API Gateway to invoke backend services [3]
resource "google_cloud_run_service_iam_member" "product_gateway_invoker" {
  location = google_cloud_run_v2_service.product.location
  project  = google_cloud_run_v2_service.product.project
  service  = google_cloud_run_v2_service.product.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.api_gateway_sa.email}"
}

resource "google_cloud_run_service_iam_member" "inventory_gateway_invoker" {
  location = google_cloud_run_v2_service.inventory.location
  project  = google_cloud_run_v2_service.inventory.project
  service  = google_cloud_run_v2_service.inventory.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.api_gateway_sa.email}"
}
