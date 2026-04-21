##############################################################################
# f7-01-apigateway-variables.tf — API Gateway specific variables
##############################################################################

variable "api_gateway_deadline" {
  description = "Backend deadline in seconds for API Gateway routes."
  type        = number
  default     = 60
}

variable "api_gateway_display_name" {
  description = "Human-readable display name for the API Gateway."
  type        = string
  default     = "Ecommerce API Gateway"
}