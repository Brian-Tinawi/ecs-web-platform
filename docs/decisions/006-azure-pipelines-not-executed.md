---
project: ecs-web-platform
date: 2026-11-05
services_chosen: []
services_rejected: [Executing the pipeline]
---
# ADR 006 — Pipeline is written, not run
The target employer's stack uses Azure DevOps. `azure-pipelines.yml` is correct and commented (build → ECR → plan → manual approval via an Environment check → apply → ECS force-new-deployment) but not executed: no Azure DevOps org is provisioned for the portfolio and the AWS side would need a service connection. GitHub Actions in this repo does fmt/validate/tflint/checkov/plan only.
