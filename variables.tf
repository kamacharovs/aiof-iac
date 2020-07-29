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

variable "appservice_auth_settings" {
  type        = map
  description = "Auth microservice application settings"
  default     = {
      "FeatureManagement:RefreshToken" = "false"
      "FeatureManagement:OpenId"       = "true"
      "Jwt:Expires"                    = "900"
      "Jwt:RefreshExpires"             = "86400"
      "Jwt:Type"                       = "Bearer"
      "Jwt:Issuer"                     = "aiof:auth"
      "Jwt:Audience"                   = "aiof:auth:audience"
      "Hash:Iterations"                = "10000"
      "Hash:SaltSize"                  = "16"
      "Hash:KeySize"                   = "32"
  }
}
variable "appsettings_auth_jwt_secret_key" {
  type        = string
  description = "Auth microservice application settings JWT secret key"
  default     = "Jwt:Secret"
}
variable "appsettings_auth_jwt_secret_value" {
  type        = string
  description = "Auth microservice application settings JWT secret value"
}
variable "appsettings_connection_string_database_key" {
  type        = string
  description = "Auth microservice application settings database connection string key"
  default     = "Database"
}
variable "appsettings_connection_string_database_value" {
  type        = string
  description = "Auth microservice application settings database connection string value"
}