variable "env" {
  type        = string
  description = "Environment based on current workspace"
}

variable "location" {
  type        = string
  description = "Resources location"
}

variable "app_service_plan_id" {
  type          = string
  description   = "App service plan id"
}

variable "application_insights_instrumentation_key" {
  type          = string
  description   = "Application insights instrumentation key"
}

variable "application_insights_connection_string" {
  type          = string
  description   = "Application insights connection string"
}