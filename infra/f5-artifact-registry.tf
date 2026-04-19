##############################################################################
# f5-artifact-registry.tf — Docker image repository in Artifact Registry
#
# All four container images (product, order, inventory, frontend) are pushed
# here by Cloud Build before `terraform apply` runs.
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

# ── Grant Cloud Build SA push/pull rights ─────────────────────────────────────
# Cloud Build uses the default compute SA: <project_number>-compute@developer.gserviceaccount.com
# We derive the project number via a data source so no manual input is needed.

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

# ── Output ────────────────────────────────────────────────────────────────────
output "artifact_registry_url" {
  description = "Base URL of the Artifact Registry Docker repository."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ecommerce.repository_id}"
}
