variable "gcp_project_id" {
  description = "The GCP project ID."
  type        = string
  default     = "your-gcp-project-id" # <-- Change this
}

variable "gcp_region" {
  description = "The GCP region for resources."
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "The name for the Cloud Run service."
  type        = string
  default     = "rearc-quest-app"
}
