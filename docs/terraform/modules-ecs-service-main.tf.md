# `modules/ecs-service/main.tf`

**Security groups (ALB → task only):**
| Resource | Rule | Why |
|---|---|---|
| `aws_security_group.alb` + `..._ingress_rule.alb_http` | TCP 80 from 0.0.0.0/0 | Public website entry |
| `..._egress_rule.alb_to_task` | TCP 8080 only to the task SG | ALB can talk to nothing else |
| `aws_security_group.task` + `..._ingress_rule.task_from_alb` | TCP 8080 **only from the ALB SG** (SG reference, not CIDR) | Tasks unreachable except via ALB |
| `..._egress_rule.task_https` | TCP 443 out | ECR pull + CloudWatch Logs through the NAT |

**Load balancing:**
| Resource | Settings | Why |
|---|---|---|
| `aws_lb.this` | application, internet-facing, public subnets, `drop_invalid_header_fields = true`, deletion protection off (lab) | Layer-7 (ADR 004); header hardening; destroyable. ~$0.0225/h |
| `aws_lb_target_group.this` | `target_type = ip` (required by Fargate awsvpc), health check `GET /health` expect 200 every 10 s, 2 healthy / 2 unhealthy, `deregistration_delay = 30` | Fast failure detection (~20 s) and fast drain |
| `aws_lb_listener.http` | :80 forward (HTTPS in prod, ADR 005) | — |

**ECS:**
| Resource | Settings | Why |
|---|---|---|
| `aws_ecs_cluster.this` | Container Insights on | Task-level CPU/mem metrics (small cost) |
| `aws_cloudwatch_log_group.app` | 365d | App logs |
| `aws_iam_role.execution` + attachment | AWS managed `AmazonECSTaskExecutionRolePolicy` | Pull image, write logs. Used by ECS agent, not the app |
| `aws_iam_role.task` | No policies | App identity with zero AWS permissions (least privilege) |
| `aws_ecs_task_definition.this` | Fargate, awsvpc, 256 CPU / 512 MiB (cheapest), `readonlyRootFilesystem`, awslogs driver, port 8080 | The *blueprint* (image, size, ports, logs, roles). Immutable revisions |
| `aws_ecs_service.this` | desired 2, FARGATE, private subnets, no public IP, circuit breaker with rollback, min healthy 100% / max 200%, 30 s health grace, `ignore_changes = [desired_count]` | The *controller* that keeps N tasks running and registered with the ALB; spreads across AZs; zero-downtime deploys; autoscaling owns the count |

**Autoscaling:** `aws_appautoscaling_target` (min 2, max 4) and `aws_appautoscaling_policy.cpu` — target tracking on average CPU 60%, scale-out cooldown 60 s, scale-in 120 s (scale out fast, in slowly).

**Alarms** (no SNS target in the lab; prod routes to a pager):
| Alarm | Metric | Threshold |
|---|---|---|
| `alb_5xx` | `HTTPCode_ELB_5XX_Count` sum | ≥5 in each of 3×60 s |
| `unhealthy_hosts` | `UnHealthyHostCount` max | ≥1 for 2×60 s |
| `latency_p95` | `TargetResponseTime` p95 | >1 s for 3×60 s |
All use `treat_missing_data = notBreaching` so idle periods don't alarm.
