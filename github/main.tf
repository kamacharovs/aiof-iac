terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "4.5.0"
    }
  }
}

provider "github" {
  token         = var.token
  organization  = var.organization
}


locals {
  master_branch = "master"
  main_branch   = "main"
}

resource "github_organization_project" "aiof" {
  name = "aiof"
  body = "All in one finance project"
}

resource "github_team" "devs" {
  name        = "devs"
  description = "Developers"
  privacy     = "closed"
}

resource "github_repository" "aiof_messaging" {
  name        = "aiof-messaging"
  description = "All in one finance messaging microservice"

  visibility    = "public"
  has_issues    = true
  has_projects  = true
  has_wiki      = true
  has_downloads = true

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