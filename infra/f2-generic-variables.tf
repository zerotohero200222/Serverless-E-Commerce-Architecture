##############################################################################
# f2-generic-variables.tf — Input variables for the entire stack
##############################################################################

# ─── Project & Region ────────────────────────────────────────────────────────
variable "project_id" {
  description = "GCP project ID where all resources will be deployed."
  type        = string
}

variable "region" {
  description = "Primary GCP region for all resources."
  type        = string
  default     = "us-central1"
}

# ─── Environment / Naming ────────────────────────────────────────────────────
variable "env" {
  description = "Deployment environment label (dev | staging | prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of: dev, staging, prod."
  }
}

variable "app_name" {
  description = "Application name used as a prefix for all resource names."
  type        = string
  default     = "ecommerce"
}

# ─── Artifact Registry ───────────────────────────────────────────────────────
variable "ar_repository_id" {
  description = "Artifact Registry Docker repository ID."
  type        = string
  default     = "ecommerce-images"
}

# ─── Container Image Tags ────────────────────────────────────────────────────
# Injected by Cloud Build as substitution variables so each build can
# carry its own unique image tag (e.g. SHORT_SHA).

variable "product_image_tag" {
  description = "Docker image tag for product-service (injected by Cloud Build)."
  type        = string
  default     = "latest"
}

variable "order_image_tag" {
  description = "Docker image tag for order-service (injected by Cloud Build)."
  type        = string
  default     = "latest"
}

variable "inventory_image_tag" {
  description = "Docker image tag for inventory-service (injected by Cloud Build)."
  type        = string
  default     = "latest"
}

variable "frontend_image_tag" {
  description = "Docker image tag for frontend-service (injected by Cloud Build)."
  type        = string
  default     = "latest"
}

# ─── Cloud Run ───────────────────────────────────────────────────────────────
variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances per service (0 = scale-to-zero)."
  type        = number
  default     = 0
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances per service."
  type        = number
  default     = 10
}

variable "cloud_run_cpu" {
  description = "CPU limit for each Cloud Run service (e.g. '1', '2')."
  type        = string
  default     = "1"
}

variable "cloud_run_memory" {
  description = "Memory limit for each Cloud Run service (e.g. '512Mi', '1Gi')."
  type        = string
  default     = "512Mi"
}

# ─── API Gateway ─────────────────────────────────────────────────────────────
variable "api_gateway_name" {
  description = "Name for the API Gateway resource."
  type        = string
  default     = "ecommerce-gateway"
}

variable "api_id" {
  description = "Logical API ID for the API Gateway API resource."
  type        = string
  default     = "ecommerce-api"
}

# ─── Cloud Armor ─────────────────────────────────────────────────────────────
variable "cloud_armor_policy_name" {
  description = "Name for the Cloud Armor security policy."
  type        = string
  default     = "ecommerce-armor-policy"
}

# ─── Load Balancer ───────────────────────────────────────────────────────────
variable "lb_name" {
  description = "Base name for all Load Balancer resources."
  type        = string
  default     = "ecommerce-lb"
}
