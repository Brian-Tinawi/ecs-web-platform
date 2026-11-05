# `modules/ecs-service/variables.tf`

Inputs of this root/module. Each is typed and described; defaults are the cheapest safe value.

| Name | Type | Default | What it does |
|---|---|---|---|
| `name_prefix` | `string` | `—` | Prefix for resource names. |
| `vpc_id` | `string` | `—` | VPC ID. |
| `public_subnet_ids` | `list(string)` | `—` | Subnets for the ALB. |
| `private_subnet_ids` | `list(string)` | `—` | Subnets for the Fargate tasks. |
| `image` | `string` | `—` | Full image reference (repo URL:tag). |
| `container_port` | `number` | `8080` | Container port. |
| `cpu` | `number` | `256` | Task vCPU units (256 = 0.25 vCPU, the cheapest Fargate size). |
| `memory` | `number` | `512` | Task memory MiB. |
| `desired_count` | `number` | `2` | Initial/minimum task count. |
| `min_count` | `number` | `2` | Autoscaling minimum. |
| `max_count` | `number` | `4` | Autoscaling maximum. |
| `cpu_target` | `number` | `60` | Target-tracking average CPU %. |
| `latency_p95_threshold_seconds` | `number` | `1` | Alarm threshold for ALB target response time p95. |
| `region` | `string` | `—` | AWS region (for log config). |
