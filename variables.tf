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

variable "postgresql_constring_name" {
  type        = string
  description = "PostgreSQL connection string name"
  default     = "PostgreSQLConnection"
}
variable "postgresql_constring_type" {
  type        = string
  description = "PostgreSQL connection string type"
  default     = "PostgreSQL"
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


variable "application_insights_application_type" {
  type        = string
  description = "Application Insights application type"
  default     = "web"
}


variable "appservice_data_version" {
  type        = string
  description = "The version of Data microservice"
  default     = "DOCKER|gkama/aiof-data:latest"
}

variable "appservice_auth_version" {
  type        = string
  description = "The version of Auth microservice"
  default     = "DOCKER|gkama/aiof-auth:latest"
}

variable "appservice_api_version" {
  type        = string
  description = "The version of API microservice"
  default     = "DOCKER|gkama/aiof-api:latest"
}

variable "appservice_metadata_version" {
  type        = string
  description = "The version of Metadata microservice"
  default     = "DOCKER|gkama/aiof-metadata:latest"
}

variable "appservice_portal_version" {
  type        = string
  description = "The version of Portal microservice"
  default     = "DOCKER|gkama/aiof-portal:latest"
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

variable "cors_github_io" {
  type        = string
  description = "github.io for cors"
  default     = "https://kamacharovs.github.io"
}

/*
Microservices OpenAPI
*/
variable "open_api" {
  type        = any
  description = "Anything OpenAPI"

  default = {
    contact_name  = "Georgi Kamacharov"
    contact_email = "gkamacharov@aiof.com"
    contact_url   = "https://github.com/gkama"

    version_auth      = "v1.0.0-alpha"
    title_auth        = "aiof.auth"
    description_auth  = "Aiof authentication microservice"
    license_name_auth = "MIT"
    license_url_auth  = "https://github.com/kamacharovs/aiof-auth/blob/master/LICENSE"

    version_api       = "v1.0.0-alpha"
    title_api         = "aiof.api"
    description_api   = "Aiof main api microservice"
    license_name_api  = "MIT"
    license_url_api   = "https://github.com/kamacharovs/aiof-api/blob/master/LICENSE"
  }
}
