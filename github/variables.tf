variable "env" {
  type        = map(string)
  description = "Environment mapping"

  default     = {
    dev   = "dev"
    qa    = "qa"
    stage = "stage"
    prod  = "prod"
  }
}

variable "token" {
  type        = string
  description = "GitHub OAuth/Personal access token"
}

variable "organization" {
  type        = string
  description = "GitHub organization account to manage"
}
