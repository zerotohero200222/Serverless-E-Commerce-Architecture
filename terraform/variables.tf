variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The primary deployment region"
  type        = string
  default     = "us-central1"
}

variable "frontend_image" {
  description = "Artifact Registry URI for the frontend container"
  type        = string
}

variable "product_image" {
  description = "Artifact Registry URI for the product container"
  type        = string
}

variable "inventory_image" {
  description = "Artifact Registry URI for the inventory container"
  type        = string
}
