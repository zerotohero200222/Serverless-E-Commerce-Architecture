#!/usr/bin/env bash
##############################################################################
# bootstrap.sh — One-time setup script
#
# Run this ONCE manually from Cloud Shell or a local terminal before the
# first Cloud Build trigger fires.  It creates the two GCS buckets needed
# for Terraform state and grants the Cloud Build SA the required roles.
#
# Usage:
#   chmod +x bootstrap.sh
#   ./bootstrap.sh
##############################################################################

set -euo pipefail

# ── Config — edit these to match your environment ────────────────────────────
PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project)}"
REGION="${REGION:-us-central1}"
ENV="${ENV:-dev}"
APP_NAME="${APP_NAME:-ecommerce}"
TF_STATE_BUCKET="${APP_NAME}-tf-state-${PROJECT_ID}"

echo "════════════════════════════════════════════════"
echo "  Bootstrap: ${APP_NAME} (${ENV})"
echo "  Project : ${PROJECT_ID}"
echo "  Region  : ${REGION}"
echo "  TF State: gs://${TF_STATE_BUCKET}"
echo "════════════════════════════════════════════════"

# ── 1. Enable prerequisite APIs ───────────────────────────────────────────────
echo "▶ Enabling prerequisite GCP APIs..."
gcloud services enable \
  cloudbuild.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  artifactregistry.googleapis.com \
  --project="${PROJECT_ID}"

# ── 2. Create Terraform state GCS bucket ──────────────────────────────────────
echo "▶ Creating Terraform state bucket: gs://${TF_STATE_BUCKET}"
if ! gsutil ls -b "gs://${TF_STATE_BUCKET}" > /dev/null 2>&1; then
  gsutil mb \
    -p "${PROJECT_ID}" \
    -l "${REGION}" \
    -b on \
    "gs://${TF_STATE_BUCKET}"
  # Enable versioning so you can recover from a bad state push
  gsutil versioning set on "gs://${TF_STATE_BUCKET}"
  echo "  ✅ Bucket created with versioning enabled."
else
  echo "  ✅ Bucket already exists — skipping."
fi

# ── 3. Get Cloud Build Service Account ────────────────────────────────────────
PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format="value(projectNumber)")
CB_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
echo "▶ Cloud Build SA: ${CB_SA}"

# ── 4. Grant Cloud Build SA required IAM roles ────────────────────────────────
echo "▶ Granting IAM roles to Cloud Build SA..."

ROLES=(
  "roles/storage.objectAdmin"          # Read/write Terraform state bucket
  "roles/run.admin"                    # Deploy Cloud Run services
  "roles/artifactregistry.admin"       # Push/pull container images
  "roles/apigateway.admin"             # Manage API Gateway
  "roles/compute.networkAdmin"         # Manage LB, NEGs, IP addresses
  "roles/compute.securityAdmin"        # Manage Cloud Armor policies
  "roles/iam.serviceAccountUser"       # Impersonate Cloud Run SA
  "roles/serviceusage.serviceUsageAdmin" # Enable GCP APIs
  "roles/apikeys.admin"                # Create/manage API keys
)

for ROLE in "${ROLES[@]}"; do
  echo "  Granting ${ROLE}..."
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${CB_SA}" \
    --role="${ROLE}" \
    --condition=None \
    --quiet
done

echo "  ✅ IAM roles granted."

# ── 5. Print Cloud Build trigger config ───────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════"
echo "  Bootstrap complete!"
echo ""
echo "  Next step: Create a Cloud Build trigger in the"
echo "  GCP Console with these substitution variables:"
echo ""
echo "  Variable              Value"
echo "  ──────────────────── ─────────────────────────────"
echo "  _PROJECT_ID           ${PROJECT_ID}"
echo "  _REGION               ${REGION}"
echo "  _ENV                  ${ENV}"
echo "  _APP_NAME             ${APP_NAME}"
echo "  _AR_REPO              ecommerce-images"
echo "  _TF_STATE_BUCKET      ${TF_STATE_BUCKET}"
echo ""
echo "  Trigger config:"
echo "    Source repo  : GitHub"
echo "    Branch       : ^main$ (or your target branch)"
echo "    Config file  : cloudbuild.yaml"
echo "════════════════════════════════════════════════"
