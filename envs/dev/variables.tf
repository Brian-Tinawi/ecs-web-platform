variable "project" {
  description = "Project slug, used in names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod)."
  type        = string
}

variable "region" {
  description = "Primary region."
  type        = string
  default     = "us-west-2"
}

variable "cost_center" {
  description = "Cost-center tag value."
  type        = string
  default     = "portfolio-lab"
}

variable "ttl" {
  description = "ISO-8601 UTC expiry for every resource (set by `make plan`, default now+4h). The TTL reaper destroys expired envs."
  type        = string

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$", var.ttl))
    error_message = "ttl must look like 2026-11-04T00:00:00Z (use `make plan`, which sets it)."
  }
}

variable "budget_email" {
  description = "Email for the per-project budget alert."
  type        = string
}

variable "monthly_budget_usd" {
  description = "Per-project monthly budget."
  type        = number
  default     = 10
}

variable "vpc_cidr" {
  description = "VPC /16 CIDR."
  type        = string
}

variable "min_tasks" {
  description = "Minimum (and initial) ECS task count."
  type        = number
  default     = 2
}

variable "max_tasks" {
  description = "Maximum ECS task count (autoscaling)."
  type        = number
  default     = 4
}
