# Enable Secret Manager API
resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# 1. Create the Secret in GCP Secret Manager
resource "google_secret_manager_secret" "postgres_password" {
  secret_id = "${terraform.workspace}-postgres-password"
  replication {
    auto {}
  }
  depends_on = [google_project_service.secretmanager]
}

# 2. Add an initial secret version dynamically generated securely
resource "random_password" "postgres_password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret_version" "postgres_password_data" {
  secret      = google_secret_manager_secret.postgres_password.id
  secret_data = random_password.postgres_password.result
}

# 3. Dedicated Service Account for the External Secrets Operator
resource "google_service_account" "eso_sa" {
  account_id   = "${terraform.workspace}-eso-sa"
  display_name = "External Secrets Operator SA"
}

# 4. IAM Workload Identity Binding
# This allows the Kubernetes Service Account used by ESO to impersonate the GCP Service Account
resource "google_service_account_iam_binding" "eso_workload_identity" {
  service_account_id = google_service_account.eso_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    # Assuming ESO is installed in the "external-secrets" namespace
    "serviceAccount:${var.project_id}.svc.id.goog[external-secrets/external-secrets]"
  ]
}

# 5. Secret Accessor Binding
# This grants the GCP Service Account read-only permission specifically to the PostgreSQL secret
resource "google_secret_manager_secret_iam_member" "eso_secret_read" {
  project   = google_secret_manager_secret.postgres_password.project
  secret_id = google_secret_manager_secret.postgres_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.eso_sa.email}"
}

output "eso_gcp_service_account" {
  value = google_service_account.eso_sa.email
  description = "The GCP SA to annotate on the External Secrets Controller"
}
