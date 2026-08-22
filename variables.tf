variable "aws_region" {
  description = "AWS region where the infrastructure is deployed"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
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
