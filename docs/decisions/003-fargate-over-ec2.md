---
project: ecs-web-platform
date: 2026-11-05
services_chosen: [Amazon ECS]
services_rejected: [ECS on EC2, EKS, App Runner]
---
# ADR 003 — ECS on Fargate
No servers to patch (the root cause of the legacy pain), per-second billing at 0.25 vCPU / 0.5 GB, native multi-AZ spreading. ECS-on-EC2 re-introduces host patching; EKS adds a $73/mo control plane and complexity a 200-person company has no team for; App Runner hides the VPC/ALB/SG story this project is meant to demonstrate.
