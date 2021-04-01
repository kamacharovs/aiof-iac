variable "env" {
  type        = string
  description = "Environment based on current workspace"
}

variable "env_tags" {
  type        = map(string)
  description = "Environment tags"
}

variable "location" {
  type        = string
  description = "Resources location"
}

variable "rg" {
  type        = any
  description = "Resource group"
}

variable "application_insights_instrumentation_key" {
  type        = string
  description = "Application insights instrumentation key"
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

variable "appservice_asset_version" {
  type        = string
  description = "The version of asset microservice"
  default     = "DOCKER|gkama/aiof-asset:latest"
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

variable "cors_github_io" {
  type        = string
  description = "github.io for cors"
  default     = "https://kamacharovs.github.io"
}

variable "appsettings_auth_jwt_private_key_value" {
  type        = string
  description = "Auth microservice application settings JWT private key value"
}
variable "appsettings_auth_jwt_public_key_value" {
  type        = string
  description = "Auth microservice application settings JWT public key value"
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

    version_asset       = "v1.0.0-alpha"
    title_asset         = "aiof.asset"
    description_asset   = "All in one finance asset microservice"
    license_name_asset  = "MIT"
    license_url_asset   = "https://github.com/kamacharovs/aiof-asset/blob/master/LICENSE"
  }
}