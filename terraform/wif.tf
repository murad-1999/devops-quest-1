# Service Account used by GitHub Actions
resource "google_service_account" "github_actions" {
  account_id   = "${terraform.workspace}-github-actions"
  display_name = "GitHub Actions Deployment SA"
}

# Grant the Service Account permissions to push to Artifact Registry
resource "google_project_iam_member" "github_actions_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Grant the Service Account permissions to deploy to GKE
resource "google_project_iam_member" "github_actions_gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Create a Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-deploy-pool"
  display_name              = "GitHub Deployment Pool"
  description               = "Identity pool for GitHub Actions integrations"
}

# Create the OIDC Provider mapped specifically for GitHub
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  description                        = "OIDC Identity Provider mapping GitHub Actions token to Google Cloud"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = "assertion.repository_owner == '${var.github_owner}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Bind the generated OIDC Token to the GitHub Actions Service Account
resource "google_service_account_iam_binding" "github_actions_oidc_bind" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    # Restricted to the specific repository 'devops-quest-1' for security (Senior-level practice)
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/murad-1999/devops-quest-1"
  ]
}

output "WIF_PROVIDER" {
  value       = google_iam_workload_identity_pool_provider.github_provider.name
  description = "The Workload Identity Provider string required by GitHub Actions"
}

output "WIF_SERVICE_ACCOUNT" {
  value       = google_service_account.github_actions.email
  description = "The identity email required by GitHub Actions"
}
