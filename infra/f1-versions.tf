##############################################################################
# f1-versions.tf — Terraform version constraints, required providers,
#                  and GCS remote state backend
##############################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  # ─── Remote State: GCS ────────────────────────────────────────────────────
  # The bucket must exist before running `terraform init`.
  # Cloud Build SA needs roles/storage.objectAdmin on this bucket.
  # Bucket name is injected via -backend-config in cloudbuild.yaml so this
  # file stays environment-agnostic.
  backend "gcs" {
  bucket = "tfstate-project-e95a0aa2-8103-46cd-9f4"
  prefix = "ecommerce/dev/terraform.tfstate"
}
}

# ─── Default Provider ────────────────────────────────────────────────────────
provider "google" {
  project = var.project_id
  region  = var.region
}

# ─── Beta Provider (needed for serverless NEG for API Gateway) ───────────────
provider "google-beta" {
  project = var.project_id
  region  = var.region
}
