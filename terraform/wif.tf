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
resource "google_project_iam_member" "github_actions_gke_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Grant the Service Account permissions to read/write the GCS Terraform state bucket.
# Required by `terraform init` to access the remote GCS backend.
# roles/storage.objectAdmin covers: list, get, create, delete, and lock state objects.
resource "google_storage_bucket_iam_member" "github_actions_tfstate" {
  bucket = "${var.project_id}-tfstate"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.github_actions.email}"
}

# ---------------------------------------------------------------------------
# Terraform execution roles
# These are required because the deploy workflow runs `terraform apply`, which
# creates/manages: VPCs, GKE clusters, service accounts, Artifact Registry
# repos, Workload Identity pools, project-level IAM bindings, and enables APIs.
# We use individual named roles (least-privilege) rather than roles/editor.
# ---------------------------------------------------------------------------

# Manage service accounts and their keys (create GKE SA, WIF bindings, etc.)
resource "google_project_iam_member" "github_actions_sa_admin" {
  project = var.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Read/write VPC networks and subnets (compute.networks.get, subnets, etc.)
resource "google_project_iam_member" "github_actions_network_admin" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Full Artifact Registry management (create repositories, not just push images)
resource "google_project_iam_member" "github_actions_ar_admin" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Enable GCP APIs via Cloud Resource Manager (serviceusage.services.enable)
resource "google_project_iam_member" "github_actions_serviceusage_admin" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Create and manage Workload Identity pools and providers (iam.workloadIdentityPools.get, etc.)
resource "google_project_iam_member" "github_actions_wif_pool_admin" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Set project-level IAM policies (required to bind roles to the GKE SA and ESO SA)
resource "google_project_iam_member" "github_actions_project_iam_admin" {
  project = var.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
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
