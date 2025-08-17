terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# 1. Enable the necessary APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com"
  ])
  service = each.key
  disable_on_destroy = false
}

# 2. Create a repository in Artifact Registry to store the Docker image
resource "google_artifact_registry_repository" "repo" {
  provider      = google
  location      = var.gcp_region
  repository_id = "${var.service_name}-repo"
  description   = "Docker repository for the Rearc quest app"
  format        = "DOCKER"
  depends_on = [
    google_project_service.apis,
  ]
}

# 3. Define the Cloud Run service (we'll add more to this later)
resource "google_cloud_run_v2_service" "app_service" {
  provider = google
  name     = var.service_name
  location = var.gcp_region

  template {
    containers {
      # We will fill this in after building the image for the first time
      image = "us-central1-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.repo.repository_id}/${var.service_name}:latest"
      
      ports {
        container_port = 3000
      }
    }
  }

  # Allow public access to the service
  iam_policy {
    policy_data = data.google_iam_policy.noauth.policy_data
  }

  depends_on = [
    google_project_service.apis,
  ]
}

# IAM policy to allow unauthenticated access
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
