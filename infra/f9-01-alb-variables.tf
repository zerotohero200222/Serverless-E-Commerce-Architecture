##############################################################################
# f9-01-alb-variables.tf — External HTTP(S) Load Balancer variables
##############################################################################

variable "lb_load_balancing_scheme" {
  description = "Load balancing scheme. EXTERNAL_MANAGED = global Application LB (recommended)."
  type        = string
  default     = "EXTERNAL_MANAGED"
}

variable "lb_protocol" {
  description = "Backend protocol for Cloud Run and API Gateway serverless backends."
  type        = string
  default     = "HTTP"
  # Cloud Run / API Gateway serverless NEGs always use HTTP internally —
  # GCP terminates TLS at the NEG boundary.
}