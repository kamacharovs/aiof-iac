resource "azurerm_app_service" "aiof_auth" {
  name                = "aiof-auth-${var.env}"
  location            = var.rg.location
  resource_group_name = var.rg.name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_auth_version

    cors {
      allowed_origins = ["https://${azurerm_app_service.aiof_portal.default_site_hostname}", var.cors_github_io]
    }
  }

  app_settings = {
    "ApplicationInsights__InstrumentationKey" = var.application_insights_instrumentation_key
    "FeatureManagement__RefreshToken"         = "true"
    "FeatureManagement__OpenId"               = "true"
    "FeatureManagement__MemCache"             = "true"
    "Data__PostgreSQL"                        = var.database_connection_string
    "Jwt__Expires"                            = "900"
    "Jwt__RefreshExpires"                     = "604800"
    "Jwt__Type"                               = "Bearer"
    "Jwt__Issuer"                             = "aiof:auth"
    "Jwt__Audience"                           = "aiof:auth:audience"
    "Jwt__PrivateKey"                         = var.appsettings_auth_jwt_private_key_value
    "Jwt__PublicKey"                          = var.appsettings_auth_jwt_public_key_value
    "Hash__Iterations"                        = "10000"
    "Hash__SaltSize"                          = "16"
    "Hash__KeySize"                           = "32"
    "OpenApi__Title"                          = var.open_api.title_auth
    "OpenApi__Description"                    = var.open_api.description_auth
    "OpenApi__Contact__Name"                  = var.open_api.contact_name
    "OpenApi__Contact__Email"                 = var.open_api.contact_email
    "OpenApi__Contact__Url"                   = var.open_api.contact_url
    "OpenApi__License__Name"                  = var.open_api.license_name_auth
    "OpenApi__License__Url"                   = var.open_api.license_url_auth
  }

  connection_string {
    name  = var.postgresql_constring_name
    type  = var.postgresql_constring_type
    value = ""
  }

  tags = var.env_tags
}

resource "azurerm_app_service" "aiof_api" {
  name                = "aiof-api-${var.env}"
  location            = var.rg.location
  resource_group_name = var.rg.name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_api_version

    cors {
      allowed_origins = ["https://${azurerm_app_service.aiof_portal.default_site_hostname}", var.cors_github_io]
    }
  }

  app_settings = {
    "ApplicationInsights__InstrumentationKey" = var.application_insights_instrumentation_key
    "FeatureManagement__Asset"                = "true"
    "FeatureManagement__Goal"                 = "true"
    "FeatureManagement__Liability"            = "true"
    "FeatureManagement__Account"              = "true"
    "FeatureManagement__UserDependent"        = "true"
    "Data__PostgreSQL"                        = var.database_connection_string
    "Jwt__Issuer"                             = "aiof:auth"
    "Jwt__Audience"                           = "aiof:auth:audience"
    "Jwt__PublicKey"                          = var.appsettings_auth_jwt_public_key_value
    "Hash__Iterations"                        = "10000"
    "Hash__SaltSize"                          = "16"
    "Hash__KeySize"                           = "32"
    "OpenApi__Version"                        = var.open_api.version_api
    "OpenApi__Title"                          = var.open_api.title_api
    "OpenApi__Description"                    = var.open_api.description_api
    "OpenApi__Contact__Name"                  = var.open_api.contact_name
    "OpenApi__Contact__Email"                 = var.open_api.contact_email
    "OpenApi__Contact__Url"                   = var.open_api.contact_url
    "OpenApi__License__Name"                  = var.open_api.license_name_api
    "OpenApi__License__Url"                   = var.open_api.license_url_api
    "RateLimit__Second"                       = "10"
    "RateLimit__Minute"                       = "120"
    "RateLimit__Hour"                         = "3600"
  }

  connection_string {
    name  = var.postgresql_constring_name
    type  = var.postgresql_constring_type
    value = ""
  }

  tags = var.env_tags
}

resource "azurerm_app_service" "aiof_metadata" {
  name                = "aiof-metadata-${var.env}"
  location            = var.rg.location
  resource_group_name = var.rg.name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_metadata_version

    cors {
      allowed_origins = ["https://${azurerm_app_service.aiof_portal.default_site_hostname}", var.cors_github_io]
    }
  }

  app_settings = {
    "WEBSITES_PORT" = "80"
  }

  tags = var.env_tags
}

resource "azurerm_app_service" "aiof_asset" {
  name                = "aiof-asset-${var.env}"
  location            = var.rg.location
  resource_group_name = var.rg.name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_asset_version

    cors {
      allowed_origins = ["https://${azurerm_app_service.aiof_portal.default_site_hostname}", var.cors_github_io]
    }
  }

  app_settings = {
    "ApplicationInsights__InstrumentationKey" = var.application_insights_instrumentation_key
    "FeatureManagement__Eventing"             = true
    "Data__PostgreSQL"                        = var.database_connection_string
    "Eventing__BaseUrl"                       = "https://${var.emitter_hostname}/api"
    "Eventing__FunctionKeyHeaderName"         = "x-functions-key"
    "Eventing__FunctionKey"                   = var.emitter_function_key
    "Jwt__Issuer"                             = "aiof:auth"
    "Jwt__Audience"                           = "aiof:auth:audience"
    "Jwt__PublicKey"                          = var.appsettings_auth_jwt_public_key_value
    "OpenApi__Title"                          = var.open_api.title_asset
    "OpenApi__Description"                    = var.open_api.description_asset
    "OpenApi__Contact__Name"                  = var.open_api.contact_name
    "OpenApi__Contact__Email"                 = var.open_api.contact_email
    "OpenApi__Contact__Url"                   = var.open_api.contact_url
    "OpenApi__License__Name"                  = var.open_api.license_name_asset
    "OpenApi__License__Url"                   = var.open_api.license_url_asset
  }
  
  tags = var.env_tags
}

resource "azurerm_app_service" "kamafi_liability" {
  name                = "kamafi-liability-${var.env}"
  location            = var.rg.location
  resource_group_name = var.rg.name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_liability_version

    cors {
      allowed_origins = ["https://${azurerm_app_service.aiof_portal.default_site_hostname}", var.cors_github_io]
    }
  }

  app_settings = {
    "ApplicationInsights__InstrumentationKey" = var.application_insights_instrumentation_key
    "Data__PostgreSQL"                        = var.database_connection_string
    "Jwt__Issuer"                             = "aiof:auth"
    "Jwt__Audience"                           = "aiof:auth:audience"
    "Jwt__PublicKey"                          = var.appsettings_auth_jwt_public_key_value
    "OpenApi__Title"                          = var.open_api.title_liability
    "OpenApi__Description"                    = var.open_api.description_liability
    "OpenApi__Contact__Name"                  = var.open_api.contact_name
    "OpenApi__Contact__Email"                 = var.open_api.contact_email
    "OpenApi__Contact__Url"                   = var.open_api.contact_url
    "OpenApi__License__Name"                  = var.open_api.license_name_liability
    "OpenApi__License__Url"                   = var.open_api.license_url_liability
  }
  
  tags = var.env_tags
}

resource "azurerm_app_service" "aiof_portal" {
  name                = "aiof-portal-${var.env}"
  location            = var.rg.location
  resource_group_name = var.rg.name
  app_service_plan_id = var.app_service_plan_id

  site_config {
    always_on        = false
    linux_fx_version = var.appservice_portal_version
  }

  app_settings = {
    "WEBSITES_PORT" = "80"
    #"REACT_APP_API_ROOT"            = "http://localhost:5001"
    #"REACT_APP_API_AUTH_ROOT"       = "https://${azurerm_app_service.aiof_auth.default_site_hostname}"
    #"REACT_APP_API_METADATA_ROOT"   = "https://${azurerm_app_service.aiof_metadata.default_site_hostname}/api"
  }

  tags = var.env_tags
}