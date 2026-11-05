variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR (a /16). Subnets are carved into /24s with cidrsubnet()."
  type        = string
}

variable "az_count" {
  description = "Number of AZs (2 = minimum for AZ-failure tolerance)."
  type        = number
  default     = 2
}
