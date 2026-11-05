# `modules/ecs-service/outputs.tf`

Outputs. All non-sensitive; the smoke tests and evidence scripts read them with `terraform output`.

| Name | What it exposes |
|---|---|
| `alb_dns_name` | Public DNS name of the ALB. |
| `alb_arn_suffix` | ALB ARN suffix (CloudWatch dimension). |
| `target_group_arn` | Target group ARN. |
| `target_group_arn_suffix` | Target group ARN suffix (CloudWatch dimension). |
| `cluster_name` | ECS cluster name. |
| `service_name` | ECS service name. |
