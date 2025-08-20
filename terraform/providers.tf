terraform {
  required_version = ">= 1.5.0"
  required_providers {
    github = { source = "integrations/github", version = "~> 6.0" }
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 4.0" }
    vercel = { source = "vercel/vercel", version = "~> 0.8" }
  }
}

provider "github" {
  token = var.github_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Note: vercel provider is community; ensure plugin installed
provider "vercel" {
  api_token = var.vercel_token
  team = var.vercel_team
}

variable "github_token" {}
variable "cloudflare_api_token" {}
variable "vercel_token" {}
variable "vercel_team" { default = null }
