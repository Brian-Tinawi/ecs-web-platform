# Interview prep — Systems Engineer phone screen (grounded in ecs-web-platform)

Short first-person answers. Numbers are from my own test run (see README "Failure-test results").

**1. Walk me through your Terraform workflow.**
`terraform init` pulls providers and configures the S3 backend; `plan` shows the diff and I save it (`-out=tfplan`); `apply tfplan` applies exactly what I reviewed. State lives remotely in S3 with native locking (`use_lockfile`), encrypted, never in Git. Reusable pieces are modules (`vpc`, `ecr`, `ecs-service`, `codebuild`); `envs/dev` and `envs/prod` are thin roots with their own tfvars and state key. Every resource gets tags via provider `default_tags`, including a `ttl`, and I run fmt/validate/tflint/checkov before any plan.

**2. ALB vs NLB?**
ALB is layer 7: it understands HTTP, so I get `/health` checks, path/host routing and per-target 5xx and latency metrics — that's what drives my alarms. NLB is layer 4 (TCP/UDP): static IPs and huge throughput, but no HTTP awareness. A website wants the ALB.

**3. A vs CNAME vs Alias?**
An A record maps a name to an IP. A CNAME maps a name to another name, but it can't sit at the zone apex and costs an extra lookup. A Route 53 Alias looks like an A record to clients but points at an AWS resource (like my ALB), works at the apex, is free to query and follows the ALB's changing IPs. So: Alias for `example.com`, CNAME only for something like `www` pointing outside AWS.

**4. Explain your subnet math and how NAT works.**
VPC is `10.20.0.0/16`. I carve /24s with `cidrsubnet(vpc, 8, n)`: public 10.20.0.0/24 and .1.0/24 for the ALB and NAT, private 10.20.10.0/24 and .11.0/24 for tasks — 251 usable IPs each (AWS reserves 5). I left gaps for future tiers. Private tasks have no public IPs; their route table sends 0.0.0.0/0 to the NAT gateway, which rewrites the source to its Elastic IP and maps replies back, so tasks can pull images but nobody can start a connection in. I used one NAT to save ~$32/month and wrote down the tradeoff: it's an outbound single point of failure for the other AZ.

**5. Task definition vs service in ECS?**
The task definition is the blueprint: image, CPU/memory, port, logging, IAM roles — versioned and immutable. The service is the controller: it keeps N copies running, registers them with the ALB, spreads them across AZs, replaces failures, and does rolling deploys with a circuit breaker. Mine: 2 tasks, 0.25 vCPU / 0.5 GB, autoscaling 2–4 at 60% CPU.

**6. How did the failover test behave?**
I probed `/health` every second. Stopping one task: 0 of 67 probes failed, full capacity back in 139 s. Stopping every task in one AZ (I raised the autoscaling minimum to 4 so each AZ had two): 0 of 77 failed, 158 s to full capacity. Visitors never noticed because the other AZ kept serving. Two honest points: I simulated the AZ loss rather than a real one, and my first attempts at the test had bugs — a wrong JMESPath key, and autoscaling overriding my manual desired count — so I fixed the harness and re-measured instead of trusting the early numbers.

**7. How would you add Cloudflare?**
Proxied DNS record to the ALB, SSL "Full (strict)" with an origin cert, WAF managed rules and rate limiting, cache static files. Then lock the ALB security group to Cloudflare's IP ranges so nobody bypasses the WAF. Trade-off: Cloudflare becomes the front door, so failover moves to Cloudflare load balancing instead of Route 53 failover.

**8. What would you do differently in production?**
HTTPS with ACM and a redirect, ALB access logs, WAF, one NAT per AZ, SNS alarms to a pager, deletion protection, KMS keys, Trivy as a gate (my ECR scan showed 4 high / 9 medium base-image findings), blue/green deploys, and a second region using Route 53 failover plus ECR replication. I skipped those on purpose for cost and wrote each down in an ADR.

**9. Linux in a Microsoft-heavy environment.**
My background is Windows/Azure/M365 administration, so I think in terms of identity, patching and uptime — and this project moves a legacy IIS server onto Linux containers. I'm comfortable on the Linux command line (this was all built from WSL), I treat Linux and Windows as tools for the same goal, and I automate the glue: PowerShell/Graph on the Microsoft side, Terraform and the AWS CLI on the cloud side. I'd pitch containers as less patching for the Windows team, not as a competing religion.

**10. Why CodeBuild instead of local Docker?**
Docker wasn't available in my environment, so Terraform creates a CodeBuild project, uploads the source, and builds and pushes the image during apply. Tags are a hash of the source because ECR tags are immutable.
