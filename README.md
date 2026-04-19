# Ecommerce Platform — GCP Infrastructure

Serverless microservices on Google Cloud Platform, deployed with Terraform and automated via Cloud Build.

## Architecture

```
Internet (Clients & Web)
         │
         ▼
External HTTP(S) Load Balancer  ←── Static Global IP
         │
         ├── /         ──────────────────────────────▶ Frontend Service (Cloud Run)
         │
         └── /api/*    ──▶ Cloud Armor (injects x-api-key)
                                │
                                ▼
                         API Gateway  ←── requires x-api-key header
                                │
                    ┌───────────┼────────────┐
                    ▼           ▼            ▼
             product-service  order-service  inventory-service
               (Cloud Run)   (Cloud Run)    (Cloud Run)
```

**Security model:**
- Direct requests to the API Gateway hostname → `401 Unauthorized` (no API key)
- Requests via Load Balancer → Cloud Armor injects `x-api-key` header automatically → `200 OK`

---

## Repository structure

```
.
├── cloudbuild.yaml                   # Cloud Build CI/CD pipeline
├── bootstrap.sh                      # One-time IAM + bucket setup
│
├── services/
│   ├── product-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── server.js
│   ├── order-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── server.js
│   ├── inventory-service/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── server.js
│   └── frontend-service/
│       ├── Dockerfile
│       ├── package.json
│       └── server.js
│
└── infra/                            # Terraform
    ├── f1-versions.tf                # Providers + GCS backend
    ├── f2-generic-variables.tf       # All input variables
    ├── f3-local-variables.tf         # Naming convention locals
    ├── f4-apis.tf                    # Enable GCP APIs
    ├── f5-artifact-registry.tf       # Docker image repository
    ├── f6-01-cloudrun-variables.tf   # Cloud Run variables
    ├── f6-02-cloudrun-product.tf     # product-service
    ├── f6-03-cloudrun-order.tf       # order-service
    ├── f6-04-cloudrun-inventory.tf   # inventory-service
    ├── f6-05-cloudrun-frontend.tf    # frontend-service
    ├── f6-06-cloudrun-outputs.tf
    ├── f7-01-apigateway-variables.tf
    ├── f7-02-apigateway.tf           # API + Config + Gateway
    ├── f7-03-apigateway-outputs.tf
    ├── f8-01-apikey.tf               # API key for Gateway auth
    ├── f9-01-alb-variables.tf
    ├── f9-02-alb-negs.tf             # Serverless NEGs
    ├── f9-03-alb-backends.tf         # Backend services
    ├── f9-04-alb-urlmap.tf           # URL map + path rules
    ├── f9-05-alb-frontend.tf         # IP + proxy + forwarding rule
    ├── f9-06-alb-outputs.tf
    ├── f10-01-cloudarmor.tf          # Cloud Armor + header injection
    ├── f10-02-cloudarmor-outputs.tf
    ├── terraform.tfvars              # Default variable values
    └── templates/
        └── openapi.yaml.tpl          # API Gateway OpenAPI spec template
```

---

## Prerequisites

- GCP project with billing enabled
- `gcloud` CLI authenticated (`gcloud auth login`)
- GitHub repository connected to Cloud Build

---

## Step 1 — One-time bootstrap

Run this **once** from Cloud Shell or a local terminal. It creates the Terraform state bucket and grants the Cloud Build SA the necessary IAM roles.

```bash
export PROJECT_ID="your-project-id"
export REGION="us-central1"
chmod +x bootstrap.sh
./bootstrap.sh
```

The script prints the exact substitution variables you need for the Cloud Build trigger.

---

## Step 2 — Add your service source code

Place each service's source code under `services/<name>/`:

```
services/
├── product-service/
│   ├── Dockerfile      ← already provided
│   ├── package.json    ← add your own
│   └── server.js       ← add your own
...
```

Each service must listen on `PORT=8080`.

---

## Step 3 — Create the Cloud Build trigger

In the GCP Console → Cloud Build → Triggers → **Create Trigger**:

| Field | Value |
|---|---|
| Event | Push to a branch |
| Repository | Your GitHub repo (connect via Cloud Build GitHub App) |
| Branch | `^main$` |
| Configuration | Cloud Build configuration file |
| File location | `cloudbuild.yaml` |

**Substitution variables** (add all of these):

| Variable | Value |
|---|---|
| `_PROJECT_ID` | your GCP project ID |
| `_REGION` | `us-central1` |
| `_ENV` | `dev` |
| `_APP_NAME` | `ecommerce` |
| `_AR_REPO` | `ecommerce-images` |
| `_TF_STATE_BUCKET` | `ecommerce-tf-state-<project-id>` |

---

## Step 4 — Update terraform.tfvars

Edit `infra/terraform.tfvars` and set `project_id` to your GCP project ID.

---

## Step 5 — Push to GitHub

```bash
git add .
git commit -m "feat: initial infra deployment"
git push origin main
```

Cloud Build triggers automatically and runs all phases.

---

## Cloud Build pipeline phases

```
PHASE 1 — Docker Builds (parallel)
  build-product   ──▶ push-product  ──┐
  build-order     ──▶ push-order    ──┤
  build-inventory ──▶ push-inventory──┤──▶ PHASE 2
  build-frontend  ──▶ push-frontend ──┘

PHASE 2 — Terraform (sequential)
  tf-init ──▶ tf-validate ──▶ tf-plan ──▶ tf-apply ──▶ PHASE 3

PHASE 3 — Smoke Test
  smoke-test (polls LB with retry for up to 5 min)
```

---

## Outputs after deployment

After `terraform apply` completes, check the Cloud Build logs for:

```
load_balancer_ip       = "X.X.X.X"
load_balancer_url      = "http://X.X.X.X"
api_gateway_url        = "https://XXXXX.gateway.dev"
product_service_url    = "https://....run.app"
order_service_url      = "https://....run.app"
inventory_service_url  = "https://....run.app"
frontend_service_url   = "https://....run.app"
```

**Test endpoints:**

```bash
LB_IP=<your-lb-ip>

# Frontend
curl http://$LB_IP/

# API routes (Cloud Armor injects key automatically)
curl http://$LB_IP/api/products
curl http://$LB_IP/api/orders
curl http://$LB_IP/api/inventory

# Direct API Gateway (should return 401 — no key)
GATEWAY_URL=<your-gateway-hostname>
curl https://$GATEWAY_URL/api/products   # → 401 Unauthorized
```

---

## Destroy infrastructure

```bash
cd infra
terraform init \
  -backend-config="bucket=ecommerce-tf-state-<project-id>" \
  -backend-config="prefix=ecommerce/dev/terraform.tfstate"

terraform destroy -auto-approve \
  -var=project_id=<your-project-id>
```

---

## Adding HTTPS (future)

1. Register a domain and create a Cloud DNS zone
2. Add `google_compute_managed_ssl_certificate` in a new `f11-ssl.tf`
3. Add `google_compute_target_https_proxy` and a port-443 forwarding rule
4. Add an HTTP→HTTPS redirect URL map on port 80
5. Point your domain A record to the LB IP

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `502 Bad Gateway` | LB not yet propagated | Wait 2–5 min after apply |
| `401` on LB route | Cloud Armor not attached | Check `f9-03-alb-backends.tf` security_policy |
| NEG unhealthy | API Gateway still provisioning | Wait, check `gcloud api-gateway gateways describe` |
| Image pull error | AR repo not yet created | Run bootstrap.sh first, re-trigger build |
| TF state locked | Previous build crashed | Run `terraform force-unlock <lock-id>` |
