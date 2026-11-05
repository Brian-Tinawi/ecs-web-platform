output "site_url" {
  description = "Public URL of the site (ALB DNS name)."
  value       = "http://${module.ecs_service.alb_dns_name}"
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs_service.cluster_name
}

output "service_name" {
  description = "ECS service name."
  value       = module.ecs_service.service_name
}

output "target_group_arn" {
  description = "Target group ARN."
  value       = module.ecs_service.target_group_arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix."
  value       = module.ecs_service.alb_arn_suffix
}

output "target_group_arn_suffix" {
  description = "Target group ARN suffix."
  value       = module.ecs_service.target_group_arn_suffix
}

output "ecr_repository" {
  description = "ECR repository name."
  value       = module.ecr.repository_name
}

output "image_tag" {
  description = "Deployed image tag."
  value       = module.codebuild.image_tag
}

output "vpc_cidr" {
  description = "VPC CIDR."
  value       = var.vpc_cidr
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  value       = module.vpc.private_subnet_cidrs
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  value       = module.vpc.public_subnet_cidrs
}
