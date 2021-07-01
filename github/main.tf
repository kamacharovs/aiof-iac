terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "4.12.1"
    }
  }
}

provider "github" {
  token   = var.token
  owner   = var.organization
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
