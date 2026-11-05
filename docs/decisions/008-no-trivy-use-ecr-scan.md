---
project: ecs-web-platform
date: 2026-11-05
services_chosen: [Amazon ECR]
services_rejected: [Trivy in CI]
---
# ADR 008 — ECR scan-on-push as the image scanner
Trivy is not installed locally and image builds happen in CodeBuild. ECR's built-in scan-on-push (enabled in Terraform) provides CVE findings with no extra tooling; the result is captured as evidence. Trivy in the pipeline is a listed production addition.
