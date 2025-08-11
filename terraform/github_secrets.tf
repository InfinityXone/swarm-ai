# Example: push secrets to a repo
variable "repo" {}
resource "github_actions_secret" "vercel_token" {
  repository  = var.repo
  secret_name = "VERCEL_TOKEN"
  plaintext_value = var.vercel_token
}
resource "github_actions_secret" "cf_api_token" {
  repository  = var.repo
  secret_name = "CF_API_TOKEN"
  plaintext_value = var.cloudflare_api_token
}
