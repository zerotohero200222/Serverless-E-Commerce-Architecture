##############################################################################
# f4-apis.tf — Enable all GCP APIs required by this stack
#
# Using disable_on_destroy = false so that destroying the Terraform stack
# does NOT disable shared project-level APIs that other workloads may rely on.
##############################################################################

locals {
  # NOTE: The API Gateway managed service (e.g. ecommerce-dev-api-XXXX.apigateway...)
  # is NOT listed here because its name is only known after API Gateway is created.
  # The `enable-apigw-managed-service` Cloud Build step enables it post-apply.
  required_apis = [
    "run.googleapis.com",                # Cloud Run
    "compute.googleapis.com",            # Load Balancer, NEGs, Cloud Armor
    "apigateway.googleapis.com",         # API Gateway
    "apikeys.googleapis.com",            # API Keys (for gateway auth)
    "servicemanagement.googleapis.com",  # Required by API Gateway internally
    "servicecontrol.googleapis.com",     # Required by API Gateway internally
    "cloudbuild.googleapis.com",         # Cloud Build CI/CD
    "artifactregistry.googleapis.com",   # Artifact Registry (container images)
    "iam.googleapis.com",                # IAM
    "cloudresourcemanager.googleapis.com", # needed by Terraform google provider
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.required_apis)

  project                    = var.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}

# ── Short convenience alias used as a dependency by downstream resources ──────
# Any resource that needs APIs enabled first should add:
#   depends_on = [google_project_service.apis]

