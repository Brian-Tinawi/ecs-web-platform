---
project: ecs-web-platform
date: 2026-11-05
services_chosen: [Amazon VPC]
services_rejected: [NAT per AZ, VPC endpoints only]
---
# ADR 002 — One NAT gateway
**Context:** Private tasks need outbound HTTPS to pull images from ECR and ship logs.
**Decision:** One NAT in public subnet AZ-a, shared by both private subnets.
**Tradeoff:** NAT is the biggest fixed cost (~$32/mo). A NAT per AZ doubles it. The risk: if AZ-a fails, tasks in AZ-b lose outbound (running tasks keep serving inbound ALB traffic; only new image pulls/log shipping fail). Accepted for a lab/dev; prod should use one NAT per AZ or ECR/Logs/S3 VPC endpoints.
**Rejected:** VPC interface endpoints (ECR api+dkr, logs, S3) cost ~$7/mo each per AZ — more than the NAT at this scale.
