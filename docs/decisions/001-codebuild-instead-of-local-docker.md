---
project: ecs-web-platform
date: 2026-11-05
services_chosen: [AWS CodeBuild]
services_rejected: [Local Docker build, GitHub Actions image build]
---
# ADR 001 — Build the image with CodeBuild, not local Docker
**Context:** Preflight showed Docker is not installed in this WSL environment (and would need sudo).
**Decision:** Terraform creates a CodeBuild project (S3 source zip of `app/`, privileged mode for `docker build`) and runs it during apply via a `terraform_data` local-exec that waits for SUCCEEDED, so ECS never starts before the image exists.
**Why not the rest:** local Docker unavailable; a GitHub Actions build would need image-push permissions in CI beyond the plan-only OIDC role.
**Consequence:** Image tag = hash of the source zip (ECR tags are IMMUTABLE). CodeBuild privileged mode is a justified checkov skip (CKV_AWS_316).
