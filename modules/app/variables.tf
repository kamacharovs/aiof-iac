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

variable "app_service_plan_id" {
  type        = string
  description = "App service plan id"
}

variable "application_insights_instrumentation_key" {
  type        = string
  description = "Application insights instrumentation key"
}

variable "database_connection_string" {
  type        = string
  description = "Database connection string"
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

variable "appservice_liability_version" {
  type        = string
  description = "The version of liability microservice"
  default     = "DOCKER|gkama/kamafi-liability:latest"
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
Eventing
*/
variable "emitter_hostname" {
  type        = string
  description = "Eventing host name"
}
variable "emitter_function_key" {
  type        = string
  description = "Eventing emitter function key"
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

    title_auth        = "aiof.auth"
    description_auth  = "Aiof authentication microservice"
    license_name_auth = "MIT"
    license_url_auth  = "https://github.com/kamacharovs/aiof-auth/blob/master/LICENSE"

    version_api       = "v1.0.0-alpha"
    title_api         = "aiof.api"
    description_api   = "Aiof main api microservice"
    license_name_api  = "MIT"
    license_url_api   = "https://github.com/kamacharovs/aiof-api/blob/master/LICENSE"

    title_asset         = "aiof.asset"
    description_asset   = "All in one finance asset microservice"
    license_name_asset  = "MIT"
    license_url_asset   = "https://github.com/kamacharovs/aiof-asset/blob/master/LICENSE"

    title_liability         = "kamafi.liability"
    description_liability   = "Kamacharov Finance liability microservice"
    license_name_liability  = "MIT"
    license_url_liability   = "https://github.com/kamacharovs/kamafi-liability/blob/master/LICENSE"
  }
}