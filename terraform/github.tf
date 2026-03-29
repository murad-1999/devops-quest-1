# Providers and secrets/variables for GitHub Actions
# Variables are defined in variables.tf

provider "github" {
  owner = var.github_owner
  # NOTE: The token is not hardcoded here for security. 
  # You must export GITHUB_TOKEN="ghp_xxx" in your shell before running terraform apply.
}

# --- Sensitive Secrets ---
resource "github_actions_secret" "wif_provider" {
  repository      = var.github_repository
  secret_name     = "WIF_PROVIDER"
  plaintext_value = google_iam_workload_identity_pool_provider.github_provider.name
}

resource "github_actions_secret" "wif_service_account" {
  repository      = var.github_repository
  secret_name     = "WIF_SERVICE_ACCOUNT"
  plaintext_value = google_service_account.github_actions.email
}

# --- Non-Sensitive Variables ---
resource "github_actions_variable" "project_id" {
  repository    = var.github_repository
  variable_name = "PROJECT_ID"
  value         = var.project_id
}

resource "github_actions_variable" "region" {
  repository    = var.github_repository
  variable_name = "REGION"
  value         = var.region
}

resource "github_actions_variable" "gke_cluster" {
  repository    = var.github_repository
  variable_name = "GKE_CLUSTER"
  value         = google_container_cluster.primary.name
}

# The NGINX Ingress IP is resolved post-cluster creation dynamically, so we inject a placeholder 
# here in terraform that you'll just manually override in the GitHub UI when the cluster provides the LB IP!
resource "github_actions_variable" "domain" {
  repository    = var.github_repository
  variable_name = "DOMAIN"
  value         = "REPLACE_ME.127.0.0.1.nip.io"
}
