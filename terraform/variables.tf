variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
  default     = "us-west1"
}

variable "machine_type" {
  type        = string
  description = "GKE Node Machine Type"
  default     = "e2-medium"
}

variable "node_count" {
  type        = number
  description = "Initial node count per zone"
  default     = 1
}

variable "max_node_count" {
  type        = number
  description = "Max node count per zone for autoscaling"
  default     = 3
}

variable "github_repository" {
  type        = string
  description = "The name of your GitHub repository (e.g. devops-quest-1)"
  default     = "devops-quest-1" 
}

variable "github_owner" {
  type        = string
  description = "The GitHub username or organization holding the repository"
  default     = "murad-1999" 
}
