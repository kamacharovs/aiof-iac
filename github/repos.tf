resource "github_repository" "aiof_metadata" {
  name        = "aiof-metadata"
  description = "All in one finance data crunching backend API"

  visibility          = "public"
  has_issues          = true
  has_projects        = true
  has_wiki            = true
  has_downloads       = true
  archive_on_destroy  = true

  allow_merge_commit  = false
  allow_rebase_merge  = false
  allow_squash_merge  = false

  topics = [
    "docker",
    "finance",
    "python",
    "uvicorn",
    "azure-pipelines",
    "fastapi"
  ]
}

resource "github_repository" "aiof_messaging" {
  name        = "aiof-messaging"
  description = "All in one finance messaging microservice"

  visibility          = "public"
  has_issues          = true
  has_projects        = true
  has_wiki            = true
  has_downloads       = true
  archive_on_destroy  = true

  allow_merge_commit  = false
  allow_rebase_merge  = false
  allow_squash_merge  = false

  topics = [
    "azure-functions-v3",
    "azure-service-bus",
    "csharp",
    "netcore31"
  ]
}

resource "github_repository" "aiof_iac" {
  name        = "aiof-iac"
  description = "All in one finance infrastructure as code"

  visibility          = "public"
  has_issues          = true
  has_projects        = true
  has_wiki            = true
  has_downloads       = true
  archive_on_destroy  = true

  allow_merge_commit  = false
  allow_rebase_merge  = false
  allow_squash_merge  = false

  topics = [
    "terraform",
    "hcl",
    "infrastructure-as-code",
    "azurerm",
    "azuread",
    "azure-pipelines"
  ]
}