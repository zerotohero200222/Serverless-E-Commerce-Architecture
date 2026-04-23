variable "cloud_run_ingress" {
  type    = string
  default = "INGRESS_TRAFFIC_ALL"
  validation {
    condition     = contains(["INGRESS_TRAFFIC_ALL", "INGRESS_TRAFFIC_INTERNAL_ONLY", "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"], var.cloud_run_ingress)
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
