output "alb_dns_name" {
  description = "Public DNS name of the ALB."
  value       = aws_lb.this.dns_name
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix (CloudWatch dimension)."
  value       = aws_lb.this.arn_suffix
}

output "target_group_arn" {
  description = "Target group ARN."
  value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
  description = "Target group ARN suffix (CloudWatch dimension)."
  value       = aws_lb_target_group.this.arn_suffix
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}
