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
  type        = map(string)
  description = "Azure resources location"

  default     = {
    dev   = "eastus"
    qa    = "eastus"
    stage = "eastus"
    prod  = "eastus"
  }
}

variable "env" {
  type        = map(string)
  description = "Environment based on current workspace"

  default     = {
    dev   = "dev"
    qa    = "qa"
    stage = "stage"
    prod  = "prod"
  }
}

variable "app" {
  type        = string
  description = "Application name"
  default     = "aiof"
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


variable "appsettings_auth_jwt_private_key_value" {
  type        = string
  description = "Auth microservice application settings JWT private key value"
}
variable "appsettings_auth_jwt_public_key_value" {
  type        = string
  description = "Auth microservice application settings JWT public key value"
}

variable "kv_jwt_private_key" {
  type        = string
  description = "PEM private key, key vault key"
  default     = "JwtPrivateKey"
}
variable "kv_jwt_public_key" {
  type        = string
  description = "PEM public key, key vault key"
  default     = "JwtPublicKey"
}
