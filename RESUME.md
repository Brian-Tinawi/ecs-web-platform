# ecs-web-platform — résumé notes

**One sentence:** Designed and deployed (Terraform, AWS) a multi-AZ ECS Fargate web platform behind an ALB with autoscaling, alarms and a measured failover, replacing a single hand-managed IIS server (fictional scenario).

## STAR bullets
- **Situation/Task→Action→Result:** A fictional 200-person company lost its site for 6 h to one AZ failure; I rebuilt it as ECS Fargate across 2 AZs in a 2-tier VPC (4 /24 subnets, ALB→task-only security groups) — **0 of 77 health probes failed** when I killed every task in one AZ, with full redundancy restored in ~2.6 min.
- Codified the platform in **4 Terraform modules / 55 resources** with remote S3 state, per-env tfvars, tag-based TTL, and a checkov-clean config (every skip justified); the whole stack deploys in ~8 min and costs an estimated **$0.37 per 4 h test deployment** (Infracost).
- Automated verification: **10 smoke/failure tests** (ALB health, 2-AZ placement, stop-one-task, lose-an-AZ) run by `make verify`; image built in CodeBuild (no local Docker); a documented Azure DevOps pipeline adds a manual approval gate before apply.

## 30-second pitch
"A company's website sat on one hand-patched IIS server, and one AZ outage cost them six hours. I rebuilt it on ECS Fargate across two availability zones behind a load balancer, all in Terraform. Then I proved it: I stopped every task in one AZ while probing the site every second and saw zero failed requests, with full capacity back in under three minutes. A test deployment costs about 37 cents, and I destroy it afterwards — the repo is the product."
