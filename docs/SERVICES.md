---
project: ecs-web-platform
services_used:
  - name: Amazon VPC
    cloud: AWS
    how: /16 VPC, 2 public + 2 private /24 subnets across 2 AZs, IGW, one NAT, route tables, REJECT flow logs
    tf_files: [modules/vpc/main.tf]
  - name: Amazon ECR
    cloud: AWS
    how: Immutable-tag repo, scan on push, keep-5 lifecycle
    tf_files: [modules/ecr/main.tf]
  - name: Amazon ECS
    cloud: AWS
    how: Fargate cluster, task definition, 2-task service across 2 AZs, CPU target-tracking autoscaling 2-4
    tf_files: [modules/ecs-service/main.tf]
  - name: Elastic Load Balancing
    cloud: AWS
    how: Internet-facing ALB, /health checks, SG chain ALB to task only
    tf_files: [modules/ecs-service/main.tf]
  - name: AWS CodeBuild
    cloud: AWS
    how: Builds and pushes the image (no local Docker), run from terraform apply
    tf_files: [modules/codebuild/main.tf]
  - name: Amazon CloudWatch
    cloud: AWS
    how: ALB 5xx, unhealthy hosts, p95 latency alarms; log groups; Container Insights
    tf_files: [modules/ecs-service/main.tf]
  - name: AWS Budgets
    cloud: AWS
    how: Monthly per-project budget with tag filter
    tf_files: [envs/dev/main.tf]
  - name: Amazon S3
    cloud: AWS
    how: Build-source bucket for the CodeBuild zip (SSE-S3, versioned, public access blocked)
    tf_files: [modules/codebuild/main.tf]
  - name: AWS STS
    cloud: AWS
    how: caller-identity data source to make the bucket name account-unique
    tf_files: [modules/codebuild/main.tf]
  - name: AWS IAM
    cloud: AWS
    how: Least-privilege roles for ECS execution/task, CodeBuild, VPC flow logs
    tf_files: [modules/ecs-service/main.tf, modules/codebuild/main.tf, modules/vpc/main.tf]
  - name: Application Auto Scaling
    cloud: AWS
    how: CPU target-tracking (60%) for the ECS service, min 2 max 4
    tf_files: [modules/ecs-service/main.tf]
services_rejected:
  - name: Amazon EKS
    reason: $73/mo control plane and Kubernetes ops overhead for a 200-person company
    instead: [Amazon ECS]
  - name: AWS App Runner
    reason: Hides the VPC/ALB/SG design this project demonstrates
    instead: [Amazon ECS]
  - name: Network Load Balancer
    reason: Layer 4 only; no HTTP health checks or per-target HTTP metrics
    instead: [Elastic Load Balancing]
---
# Services used in ecs-web-platform

## Amazon VPC
- **Service:** Amazon VPC
- **Cloud:** AWS
- **How we used it:** see `modules/vpc/main.tf`; 10.20.0.0/16, /24 subnets, single NAT
- **Why we chose it:** required network boundary; private subnets keep tasks off the internet
- **Alternatives rejected and why:** per-AZ NAT (2x fixed cost, ADR 002); VPC endpoints (more expensive at this scale)
- **Gotchas:** one NAT = outbound SPOF for the other AZ
- **Cost:** estimated, NAT ~$0.045/h (infracost)

## Amazon ECR
- **Service:** Amazon ECR
- **Cloud:** AWS
- **How we used it:** `modules/ecr/main.tf`; IMMUTABLE tags, scan on push, keep 5
- **Why we chose it:** native to ECS, IAM-controlled pulls, built-in scanning
- **Alternatives rejected and why:** Docker Hub (rate limits, public); GHCR (extra credentials)
- **Gotchas:** immutable tags force unique tags per build (we use a source hash)
- **Cost:** estimated, pennies for <1 GB

## Amazon ECS
- **Service:** Amazon ECS
- **Cloud:** AWS
- **How we used it:** `modules/ecs-service/main.tf`; Fargate 0.25 vCPU/0.5 GB x2, circuit breaker, autoscaling 2-4 @ CPU 60%
- **Why we chose it:** no hosts to patch; AZ-spread scheduling (ADR 003)
- **Alternatives rejected and why:** EKS, App Runner, ECS on EC2
- **Gotchas:** `ignore_changes = [desired_count]` so autoscaling is not fought by Terraform
- **Cost:** estimated, ~$0.03/h for 2 tasks

## Elastic Load Balancing
- **Service:** Elastic Load Balancing
- **Cloud:** AWS
- **How we used it:** `modules/ecs-service/main.tf`; ALB, ip target group, /health every 10 s
- **Why we chose it:** layer-7 health checks and metrics (ADR 004)
- **Alternatives rejected and why:** NLB
- **Gotchas:** HTTP only in the lab (ADR 005)
- **Cost:** estimated, ~$0.0225/h + LCU

## AWS CodeBuild
- **Service:** AWS CodeBuild
- **Cloud:** AWS
- **How we used it:** `modules/codebuild/main.tf`; S3 source, privileged mode, started by terraform_data
- **Why we chose it:** Docker was unavailable locally (ADR 001)
- **Alternatives rejected and why:** local Docker; GitHub Actions build
- **Gotchas:** privileged mode needed for docker build
- **Cost:** estimated, ~$0.005/min of build

## Amazon CloudWatch
- **Service:** Amazon CloudWatch
- **Cloud:** AWS
- **How we used it:** 3 alarms, log groups, Container Insights, metric widget images for evidence
- **Why we chose it:** native signals for ALB/ECS
- **Alternatives rejected and why:** third-party APM (cost, out of scope)
- **Gotchas:** alarms have no SNS target in the lab
- **Cost:** estimated, <$1 per deployment

## AWS Budgets
- **Service:** AWS Budgets
- **Cloud:** AWS
- **How we used it:** `envs/*/main.tf` budget filtered by project tag, alerts at 80%/100%
- **Why we chose it:** mandatory cost guardrail
- **Alternatives rejected and why:** Cost Anomaly Detection (not budget-bound)
- **Gotchas:** tag filter needs the cost-allocation tag activated
- **Cost:** first 2 budgets free

## Amazon S3
- **Service:** Amazon S3
- **Cloud:** AWS
- **How we used it:** build-source bucket in `modules/codebuild/main.tf`
- **Why we chose it:** needed for the CodeBuild pipeline (ADR 001)
- **Alternatives rejected and why:** n/a
- **Gotchas:** none
- **Cost:** estimated, negligible

## AWS STS
- **Service:** AWS STS
- **Cloud:** AWS
- **How we used it:** account-ID lookup in `modules/codebuild/main.tf`
- **Why we chose it:** needed for the CodeBuild pipeline (ADR 001)
- **Alternatives rejected and why:** n/a
- **Gotchas:** none
- **Cost:** estimated, negligible

## AWS IAM
- **Service:** AWS IAM
- **Cloud:** AWS
- **How we used it:** execution, task, build and flow-log roles
- **Why we chose it:** least privilege / hands-off scaling
- **Alternatives rejected and why:** shared admin roles (too broad); scheduled scaling (not load-driven)
- **Gotchas:** autoscaling overrides manual desired-count changes
- **Cost:** estimated, free

## Application Auto Scaling
- **Service:** Application Auto Scaling
- **Cloud:** AWS
- **How we used it:** ECS target tracking
- **Why we chose it:** least privilege / hands-off scaling
- **Alternatives rejected and why:** shared admin roles (too broad); scheduled scaling (not load-driven)
- **Gotchas:** autoscaling overrides manual desired-count changes
- **Cost:** estimated, free
