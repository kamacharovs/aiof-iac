locals {
  default_branch      = "main"
  github_pages_branch = "github-pages"
  github_pages_path   = "/docs"

  dev_rg           = "aiof-dev"
  dev                 = {
    portal_app_name   = "aiof-portal-dev"
    portal_app_rg     = local.dev_rg
    asset_app_name    = "aiof-asset-dev"
    asset_app_rg      = local.dev_rg
  }
}

/*
Metadata
*/
resource "github_repository" "aiof_metadata" {
  name        = "aiof-metadata"
  description = "All in one finance data crunching backend API"

  visibility          = "public"
  has_issues          = true
  has_projects        = true
  has_wiki            = true
  has_downloads       = true
  archive_on_destroy  = true

  allow_merge_commit  = true
  allow_rebase_merge  = true
  allow_squash_merge  = true

  vulnerability_alerts  = true

  topics = [
    "docker",
    "finance",
    "python",
    "uvicorn",
    "azure-pipelines",
    "fastapi"
  ]
}

/*
Messaging
*/
resource "github_repository" "aiof_messaging" {
  name        = "aiof-messaging"
  description = "All in one finance messaging microservice"

  visibility          = "public"
  has_issues          = true
  has_projects        = true
  has_wiki            = true
  has_downloads       = true
  archive_on_destroy  = true

  allow_merge_commit  = true
  allow_rebase_merge  = true
  allow_squash_merge  = true

  vulnerability_alerts  = true

  topics = [
    "azure-functions-v3",
    "azure-service-bus",
    "csharp",
    "netcore31"
  ]
}

/*
IaC
*/
resource "github_repository" "aiof_iac" {
  name        = "aiof-iac"
  description = "All in one finance infrastructure as code"

  visibility          = "public"
  has_issues          = true
  has_projects        = true
  has_wiki            = true
  has_downloads       = true
  archive_on_destroy  = true

  allow_merge_commit  = true
  allow_rebase_merge  = true
  allow_squash_merge  = true

  vulnerability_alerts  = true

  topics = [
    "terraform",
    "hcl",
    "infrastructure-as-code",
    "azurerm",
    "azuread",
    "azure-pipelines"
  ]
}

/*
Portal
  Environments
  Environment variables
*/
resource "github_repository" "aiof_portal" {
  name        = "aiof-portal"
  description = "All in one finance front end UI"

  visibility          = "public"
  has_issues          = true
  has_projects        = true
  has_wiki            = true
  has_downloads       = true
  archive_on_destroy  = true

  allow_merge_commit  = true
  allow_rebase_merge  = true
  allow_squash_merge  = true

  vulnerability_alerts  = true

  topics = [
    "react",
    "javascript",
    "docker",
    "frontend"
  ]
}

resource "github_repository_environment" "aiof_portal_env_dev" {
  environment = "dev"
  repository  = github_repository.aiof_portal.name
}
resource "github_actions_environment_secret" "aiof_portal_ev_app_name" {
  repository       = github_repository.aiof_portal.name
  environment      = github_repository_environment.aiof_portal_env_dev.environment
  secret_name      = "AZURE_APP_NAME"
  plaintext_value  = local.dev.portal_app_name
}
resource "github_actions_environment_secret" "aiof_portal_ev_app_rg" {
  repository       = github_repository.aiof_portal.name
  environment      = github_repository_environment.aiof_portal_env_dev.environment
  secret_name      = "AZURE_APP_RESOURCE_GROUP"
  plaintext_value  = local.dev.portal_app_rg
}

/*
Asset
*/
resource "github_repository" "aiof_asset" {
  name        = "aiof-asset"
  description = "All in one finance asset microservice"

  visibility          = "public"
  has_issues          = true
  has_projects        = true
  has_wiki            = true
  has_downloads       = true
  archive_on_destroy  = true

  allow_merge_commit  = true
  allow_rebase_merge  = true
  allow_squash_merge  = true

  gitignore_template  = "VisualStudio"
  license_template    = "mit"

  vulnerability_alerts  = true

  pages {
    source {
      branch  = local.github_pages_branch
      path    = local.github_pages_path
    }
  }

  topics = [
    "docker",
    "finance",
    "csharp",
    "dotnet5",
    "postgresql",
    "azure-devops",
    "azure-pipelines"
  ]
}
resource "github_branch" "aiof_asset_github_pages" {
  repository    = github_repository.aiof_asset.name
  branch        = local.github_pages_branch
  source_branch = local.default_branch
}

resource "github_repository_environment" "aiof_asset_env_dev" {
  environment = "dev"
  repository  = github_repository.aiof_asset.name
}
resource "github_actions_environment_secret" "aiof_asset_ev_app_name" {
  repository       = github_repository.aiof_asset.name
  environment      = github_repository_environment.aiof_asset_env_dev.environment
  secret_name      = "AZURE_APP_NAME"
  plaintext_value  = local.dev.asset_app_name
}
resource "github_actions_environment_secret" "aiof_asset_ev_app_rg" {
  repository       = github_repository.aiof_asset.name
  environment      = github_repository_environment.aiof_asset_env_dev.environment
  secret_name      = "AZURE_APP_RESOURCE_GROUP"
  plaintext_value  = local.dev.asset_app_rg
}

/*
Eventing emitter
*/
resource "github_repository" "aiof_eventing_emitter" {
  name        = "aiof-eventing-emitter"
  description = "All in one finance eventing emitter"

  visibility          = "public"
  has_issues          = true
  has_projects        = true
  has_wiki            = true
  has_downloads       = true
  archive_on_destroy  = true

  allow_merge_commit  = true
  allow_rebase_merge  = true
  allow_squash_merge  = true

  gitignore_template  = "VisualStudio"
  license_template    = "mit"

  vulnerability_alerts  = true

  topics = [
    "docker",
    "finance",
    "csharp",
    "dotnet5",
    "azure-functions",
    "event-driven",
    "event-emitter",
    "azure-devops",
    "azure-pipelines"
  ]
}