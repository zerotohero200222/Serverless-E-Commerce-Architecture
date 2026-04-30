##############################################################################
# f5-artifact-registry.tf — Docker image repository in Artifact Registry
# IAM bindings managed via gcloud in cloudbuild.yaml, not Terraform
##############################################################################

resource "google_artifact_registry_repository" "ecommerce" {
  project       = var.project_id
  location      = var.region
  repository_id = var.ar_repository_id
  description   = "Docker images for the ${var.app_name} microservices (${var.env})"
  format        = "DOCKER"
  labels        = local.common_labels
  depends_on    = [google_project_service.apis]
}

data "google_project" "current" {
  project_id = var.project_id
}

output "artifact_registry_url" {
  description = "Base URL of the Artifact Registry Docker repository."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ecommerce.repository_id}"
}
