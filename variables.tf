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

variable "gkama_object_id" {
  type        = string
  description = "gkama's object id"
}


variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.17"
}


variable "application_insights_application_type" {
  type        = string
  description = "Application Insights application type"
  default     = "web"
}


variable "appservice_auth_version" {
  type        = string
  description = "The .NET Core version of App Services"
  default     = "DOCKER|gkama/aiof-auth:latest"
}

variable "appservice_api_version" {
  type        = string
  description = "The .NET Core version of App Services"
  default     = "DOCKER|gkama/aiof-api:latest"
}

variable "appservice_metadata_version" {
  type        = string
  description = "The Docker image version of App Services"
  default     = "DOCKER|gkama/aiof-metadata:latest"
}

variable "appservice_portal_version" {
  type        = string
  description = "The Docker image version of App Services"
  default     = "DOCKER|gkama/aiof-portal:latest"
}

variable "appservice_auth_settings" {
  type        = map
  description = "Auth microservice application settings"
  default     = {
      "FeatureManagement__RefreshToken" = "true"
      "FeatureManagement__OpenId"       = "true"
      "FeatureManagement__MemCache"     = "true"
      "MemCache__Ttl"                   = "900"
      "PostgreSQL"                      = ""
      "Jwt__Expires"                    = "900"
      "Jwt__RefreshExpires"             = "604800"
      "Jwt__Type"                       = "Bearer"
      "Jwt__Issuer"                     = "aiof:auth"
      "Jwt__Audience"                   = "aiof:auth:audience"
      "Hash__Iterations"                = "10000"
      "Hash__SaltSize"                  = "16"
      "Hash__KeySize"                   = "32"
      "OpenApi__Version"                = "v1.0.0-alpha"
      "OpenApi__Title"                  = "aiof.auth"
      "OpenApi__Description"            = "Aiof authentication microservice"
      "OpenApi__Contact__Name"          = "Georgi Kamacharov"
      "OpenApi__Contact__Email"         = "gkamacharov@aiof.com"
      "OpenApi__Contact__Url"           = "https://github.com/gkama"
      "OpenApi__License__Name"          = "MIT"
      "OpenApi__License__Url"           = "https://github.com/kamacharovs/aiof-auth/blob/master/LICENSE"
  }
}
variable "appsettings_auth_jwt_private_key" {
  type        = string
  description = "Auth microservice application settings JWT private key"
  default     = "Jwt__PrivateKey"
}
variable "appsettings_auth_jwt_private_key_value" {
  type        = string
  description = "Auth microservice application settings JWT private key value"
}
variable "appsettings_auth_jwt_public_key" {
  type        = string
  description = "Auth microservice application settings JWT public key"
  default     = "Jwt__PublicKey"
}
variable "appsettings_auth_jwt_public_key_value" {
  type        = string
  description = "Auth microservice application settings JWT public key value"
}

variable "appservice_api_settings" {
  type        = map
  description = "API microservice application settings"
  default     = {
      "FeatureManagement__Asset"        = "true"
      "FeatureManagement__Goal"         = "true"
      "FeatureManagement__Liability"    = "true"
      "PostgreSQL"                      = ""
      "Polly__DefaultRetry"             = "2"
      "Metadata__BaseUrl"               = ""
      "Metadata__DefaultFrequency"      = "monthly"
      "Jwt__Issuer"                     = "aiof:auth"
      "Jwt__Audience"                   = "aiof:auth:audience"
      "Hash__Iterations"                = "10000"
      "Hash__SaltSize"                  = "16"
      "Hash__KeySize"                   = "32"
      "OpenApi__Version"                = "v1.0.0-alpha"
      "OpenApi__Title"                  = "aiof.api"
      "OpenApi__Description"            = "Aiof main api microservice"
      "OpenApi__Contact__Name"          = "Georgi Kamacharov"
      "OpenApi__Contact__Email"         = "gkamacharov@aiof.com"
      "OpenApi__Contact__Url"           = "https://github.com/gkama"
      "OpenApi__License__Name"          = "MIT"
      "OpenApi__License__Url"           = "https://github.com/kamacharovs/aiof-api/blob/master/LICENSE"
  }
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