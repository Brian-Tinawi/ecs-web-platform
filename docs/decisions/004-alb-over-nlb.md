---
project: ecs-web-platform
date: 2026-11-05
services_chosen: [Elastic Load Balancing]
services_rejected: [Network Load Balancer]
---
# ADR 004 — ALB (layer 7)
HTTP health checks on /health, path/host routing for later, per-target 5xx/latency metrics that drive the alarms. NLB (layer 4) is for TCP/UDP, static IPs, or extreme throughput — none needed.
