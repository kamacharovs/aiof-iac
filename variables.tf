variable "subscription_id" {
  type        = string
  description = "Azure Subscription"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant id"
}

variable "client_id" {
  type        = string
  description = "Azure Service Principle (App Registration) client id"
}

variable "client_secret" {
  type        = string
  description = "Azure Service Principle (App Registration) client secret"
}

variable "location" {
  type        = string
  description = "Azure resources location"
  default     = "eastus"
}

variable "env" {
  type        = string
  description = "Azure resource environment"
  default     = "dev"
}

variable "db_admin_username" {
  type        = string
  description = "Database admin username"
}

variable "db_admin_password" {
  type        = string
  description = "Database admin password"
}

variable "db_admin_start_ip" {
  type        = string
  description = "Database admin IP address"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.17"
}

variable "appservice_version" {
  type        = string
  description = "The .NET Core version of App Services"
  default     = "DOTNETCORE|3.1"
}