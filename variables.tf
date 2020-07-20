variable "subscription_id" {
  description = "Azure Subscription"
}

variable "tenant_id" {
  description = "Azure Tenant id"
}

variable "client_id" {
  description = "Azure Service Principle (App Registration) client id"
}

variable "client_secret" {
  description = "Azure Service Principle (App Registration) client secret"
}

variable "location" {
  description = "Azure resources location"
  default     = "eastus"
}

variable "env" {
  description = "Azure resource environment"
  default     = "dev"
}

variable "db_admin_username" {
  description = "Database admin username"
}

variable "db_admin_password" {
  description = "Database admin password"
}

variable "db_admin_start_ip" {
  description = "Database admin IP address"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  default = "1.17"
}