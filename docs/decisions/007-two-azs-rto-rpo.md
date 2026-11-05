---
project: ecs-web-platform
date: 2026-11-05
services_chosen: [Amazon ECS]
services_rejected: [Multi-region active/passive (designed only)]
---
# ADR 007 — Multi-AZ now, multi-region designed
The legacy outage was an AZ failure, so multi-AZ answers the stated problem. Stateless site → RPO = 0 (no data to lose; image is in ECR, config is in Git). RTO is measured by the failover tests (see README). Multi-region (Route 53 failover, ECR replication) is written up but out of scope for cost/time.
