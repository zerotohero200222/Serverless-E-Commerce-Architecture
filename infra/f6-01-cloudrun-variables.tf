variable "cloud_run_ingress" {
  type    = string
  default = "all"
  validation {
    condition     = contains(["all", "internal", "internal-and-cloud-load-balancing"], var.cloud_run_ingress)
    error_message = "Must be one of: all, internal, internal-and-cloud-load-balancing."
  }
}
variable "cloud_run_concurrency" {
  type    = number
  default = 80
}
variable "cloud_run_timeout_seconds" {
  type    = number
  default = 60
}
