variable "env" {
  type        = string
  description = "Environment based on current workspace"
}

variable "location" {
  type        = string
  description = "Resources location"
}

variable "rg" {
  type        = any
  description = "Resource group"
}

variable "ai_application_type" {
  type        = string
  description = "Application Insights application type"
  default     = "web"
}

variable "aiof_auth_hostname" {
  type        = string
  description = "Aiof auth site hostname"
}
variable "aiof_api_hostname" {
  type        = string
  description = "Aiof api site hostname"
}
variable "aiof_metadata_hostname" {
  type        = string
  description = "Aiof metadata site hostname"
}