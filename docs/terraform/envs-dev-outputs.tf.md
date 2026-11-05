# `envs/dev/outputs.tf`

Outputs. All non-sensitive; the smoke tests and evidence scripts read them with `terraform output`.

| Name | What it exposes |
|---|---|
| `site_url` | Public URL of the site (ALB DNS name). |
| `cluster_name` | ECS cluster name. |
| `service_name` | ECS service name. |
| `target_group_arn` | Target group ARN. |
| `alb_arn_suffix` | ALB ARN suffix. |
| `target_group_arn_suffix` | Target group ARN suffix. |
| `ecr_repository` | ECR repository name. |
| `image_tag` | Deployed image tag. |
| `vpc_cidr` | VPC CIDR. |
| `private_subnet_cidrs` | Private subnet CIDRs. |
| `public_subnet_cidrs` | Public subnet CIDRs. |
