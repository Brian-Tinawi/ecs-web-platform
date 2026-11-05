# ecs-web-platform — project context

- Scenario (fictional): Contoso Harbor Supply — 200-person marine-parts distributor; customer website ran on one hand-managed EC2/IIS server, and an AZ outage cost 6 hours of downtime.
- Cloud: AWS · Region: us-west-2 · Advanced feature: multi-AZ self-healing + target-tracking autoscaling (failure-tested; multi-region designed, not built)
- State: S3 (native locking) key `projects/ecs-web-platform/<env>.tfstate`
- Image build: AWS CodeBuild (no local Docker in WSL — ADR 001); tags are content-hashed because ECR is IMMUTABLE.
- Conventions: modules in `modules/` (vpc, ecr, ecs-service, codebuild), roots in `envs/<env>`; `make plan ENV=dev` then
  `terraform -chdir=envs/dev apply tfplan`; `make verify ENV=dev` runs smoke + failover tests; tags via provider `default_tags` incl. ttl.
- Azure DevOps pipeline (`azure-pipelines.yml`) is documentation-grade only: never executed (ADR 006).
- Memory: keep `docs/STATE.md`, `docs/SERVICES.md`, `docs/SESSION_LOG.md`, `docs/decisions/` current.
- Global rules: `~/.claude/CLAUDE.md`. Portfolio index: `~/cloud-portfolio/PORTFOLIO.md`.
