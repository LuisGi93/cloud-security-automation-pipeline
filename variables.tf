variable "aws_region" {
  description = "AWS region where the infrastructure is deployed"
  type        = string
}

variable "tfstate_bucket_name" {
  description = "Name of the S3 bucket used as Terraform remote backend"
  type        = string
}

variable "project_name" {
  description = "Project name (used in tags)"
  type        = string
  default     = "cloud-security-automation-pipeline"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "personal"
}

variable "owner" {
  description = "Resource owner (used in tags)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the CI role via OIDC. Uses the immutable subject format (owner@owner_id/repo@repo_id) since this repo was created after GitHub's July 15, 2026."
  type        = string
  default     = "LuisGi93@17405573/cloud-security-automation-pipeline@1338709143"

}

variable "state_key" {
  type        = string
  default     = "cloud-security-automation-pipeline/terraform.tfstate"
  description = "S3 key used for the Terraform remote state"
}
