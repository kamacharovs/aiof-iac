variable "env" {
  type        = string
  description = "Environment based on current workspace"
}

variable "location" {
  type        = string
  description = "Resources location"
}

variable "messaging_sbns_sku" {
  type        = map(string)
  description = "The sku of the service bus namespace"

  default     = {
    dev   = "Basic"
    qa    = "Basic"
    stage = "Basic"
    prod  = "Basic"
  }
}

variable "app_service_plan_id" {
  type          = string
  description   = "App service plan id"
}