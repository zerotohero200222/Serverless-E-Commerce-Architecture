##############################################################################
# f5-artifact-registry.tf — Docker image repository in Artifact Registry
#
# The repo is pre-created by the `create-ar-repo` Cloud Build step so images
# can be pushed before Terraform runs.  The `terraform import` step in
# cloudbuild.yaml syncs it into state before tf-plan runs, so Terraform
# never tries to create it and never hits a 409 conflict.
##############################################################################

resource "google_artifact_registry_repository" "ecommerce" {
  project       = var.project_id
  location      = var.region
  repository_id = var.ar_repository_id
  description   = "Docker images for the ${var.app_name} microservices (${var.env})"
  format        = "DOCKER"

  labels = local.common_labels

  depends_on = [google_project_service.apis]
}

data "google_project" "current" {
  project_id = var.project_id
}

resource "google_artifact_registry_repository_iam_member" "cloudbuild_push" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.ecommerce.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

output "artifact_registry_url" {
  description = "Base URL of the Artifact Registry Docker repository."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ecommerce.repository_id}"
}
