# `modules/vpc/outputs.tf`

Outputs. All non-sensitive; the smoke tests and evidence scripts read them with `terraform output`.

| Name | What it exposes |
|---|---|
| `vpc_id` | VPC ID. |
| `public_subnet_ids` | Public subnet IDs (ALB). |
| `private_subnet_ids` | Private subnet IDs (Fargate tasks). |
| `public_subnet_cidrs` | Public subnet CIDRs. |
| `private_subnet_cidrs` | Private subnet CIDRs. |
