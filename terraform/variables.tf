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
