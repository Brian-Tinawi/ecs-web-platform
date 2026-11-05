variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "app_dir" {
  description = "Path to the app directory (Dockerfile + code) to build."
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL to push to."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN (scopes the push permission)."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}
