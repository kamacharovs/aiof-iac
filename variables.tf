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


variable "postgresql_sku_name" {
  type        = string
  description = "PostgreSQL Sku Name"
  default     = "B_Gen5_2"
}

variable "postgresql_version" {
  type        = string
  description = "PostgreSQL version"
  default     = "11"
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
  default     = "DOCKER|gkama/aiof-auth:latest"
}

variable "appservice_auth_settings" {
  type        = map
  description = "Auth microservice application settings"
  default     = {
      "FeatureManagement__RefreshToken" = "false"
      "FeatureManagement__OpenId"       = "true"
      "PostgreSQL"                      = ""
      "Jwt__Expires"                    = "900"
      "Jwt__RefreshExpires"             = "86400"
      "Jwt__Type"                       = "Bearer"
      "Jwt__Issuer"                     = "aiof:auth"
      "Jwt__Audience"                   = "aiof:auth:audience"
      "Hash__Iterations"                = "10000"
      "Hash__SaltSize"                  = "16"
      "Hash__KeySize"                   = "32"
  }
}
variable "appsettings_auth_jwt_secret_key" {
  type        = string
  description = "Auth microservice application settings JWT secret key"
  default     = "Jwt__Secret"
}
variable "appsettings_auth_jwt_secret_value" {
  type        = string
  description = "Auth microservice application settings JWT secret value"
}