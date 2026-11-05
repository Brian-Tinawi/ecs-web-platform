variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnets for the ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnets for the Fargate tasks."
  type        = list(string)
}

variable "image" {
  description = "Full image reference (repo URL:tag)."
  type        = string
}

variable "container_port" {
  description = "Container port."
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Task vCPU units (256 = 0.25 vCPU, the cheapest Fargate size)."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory MiB."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Initial/minimum task count."
  type        = number
  default     = 2
}

variable "min_count" {
  description = "Autoscaling minimum."
  type        = number
  default     = 2
}

variable "max_count" {
  description = "Autoscaling maximum."
  type        = number
  default     = 4
}

variable "cpu_target" {
  description = "Target-tracking average CPU %."
  type        = number
  default     = 60
}

variable "latency_p95_threshold_seconds" {
  description = "Alarm threshold for ALB target response time p95."
  type        = number
  default     = 1
}

variable "region" {
  description = "AWS region (for log config)."
  type        = string
}
