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

resource "github_team" "devs" {
  name        = "devs"
  description = "Developers"
  privacy     = "closed"
}