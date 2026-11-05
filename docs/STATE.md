# ecs-web-platform — STATE (living brain of the project)

**Status:** published (public repo; dev destroyed)
**Last updated:** 2026-11-05
**Last verified (deploy → smoke → destroy):** 2026-11-05 (dev, 10/10 checks)

## What's built
- modules: vpc, ecr, ecs-service (ALB + ECS + autoscaling + alarms), codebuild; envs dev/prod (prod plan-only, 10.30.0.0/16)
- app/ (Python /health + AZ page), azure-pipelines.yml (documented, not executed), smoke + failover tests, ADRs 001–008, docs for every .tf, INTERVIEW_PREP.md

## What's deployed
- Nothing. Dev destroyed 2026-11-05 and verified empty (ECS/ALB/NAT/EIP/VPC/ECR/CodeBuild all 0).

## Open issues
- Bootstrap `github_repos` NOT updated (needs Brian's OK: it adds Entra federated credentials). AWS already trusts all Brian-Tinawi repos, so the plan workflow works once `AWS_PLAN_ROLE_ARN` repo variable is set.
- ECR scan: 4 HIGH / 9 MEDIUM / 3 LOW in python:3.12-slim base (no fix applied).
- Actual cost not yet pulled (billing lag): see docs/evidence/runs.md.

## Next steps
- [ ] Set repo variable AWS_PLAN_ROLE_ARN; add repo to bootstrap github_repos if CI plan should run
- [ ] Optional: Trivy gate, HTTPS + domain, second region

## Known gotchas
- ECR tags are IMMUTABLE → image tag = source hash; manual desired-count changes are overridden by autoscaling (raise the autoscaling MIN to force a size).
- ALB keeps a dying target "healthy" briefly: recovery timing waits until stopped tasks are STOPPED.
- Docker not installed in WSL: images built by CodeBuild (ADR 001).

## Costs observed
| Date | Env | Estimated (infracost) | Actual (billing) | Notes |
|---|---|---|---|---|
| 2026-11-05 | dev | $0.0926/h, $0.37 per 4 h (ran ~1.5 h) | pending | 55 resources |

## Remember
- 2026-11-05: Brian asked for an autonomous run; no GIF, no /ship-project, no Azure DevOps execution, no CloudFront/blue-green/2nd region.
