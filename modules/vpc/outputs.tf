output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (ALB)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (Fargate tasks)."
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  value       = aws_subnet.private[*].cidr_block
}
