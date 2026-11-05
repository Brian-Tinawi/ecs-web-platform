# `modules/vpc/main.tf`

**Subnet math:** VPC is a /16 (65,536 addresses). `cidrsubnet(vpc, 8, n)` carves /24s (256 addresses, 251 usable after AWS's 5 reserved). Public = n 0–1 (10.20.0.0/24, 10.20.1.0/24); private = n 10–11 (10.20.10.0/24, 10.20.11.0/24). The gap (n 2–9) leaves room for more public tiers; n 12+ for data/other tiers, without renumbering.

| Resource | What / why | Security / cost |
|---|---|---|
| `data.aws_availability_zones.available` + `locals` | Picks the first `az_count` (2) AZs and builds subnet lists | 2 AZs is the minimum to survive an AZ outage |
| `aws_vpc.this` | The network. DNS support + hostnames on (needed for ECR/CloudWatch name resolution) | Free |
| `aws_default_security_group.this` | Adopts the default SG with **no rules** | Prevents accidental use of an open default SG |
| `aws_internet_gateway.this` | Inbound/outbound internet for public subnets | Free |
| `aws_subnet.public` (x2) | ALB + NAT live here. `map_public_ip_on_launch = false` — nothing gets a public IP by accident | Only the ALB/NAT are internet-facing |
| `aws_subnet.private` (x2) | Fargate tasks live here, no public IPs | Tasks unreachable from the internet except via the ALB |
| `aws_eip.nat` | Static public IP for the NAT | ~$3.60/mo while allocated |
| `aws_nat_gateway.this` | ONE NAT in public subnet 0: private → internet (egress only). Source-NAT: private IP rewritten to the EIP, replies mapped back; no inbound connections can start from outside | ~$0.045/h + data; single NAT is a deliberate tradeoff (ADR 002) |
| `aws_route_table.public` / `aws_route.public_internet` / associations | 0.0.0.0/0 → IGW for public subnets | — |
| `aws_route_table.private` / `aws_route.private_nat` / associations | 0.0.0.0/0 → NAT for private subnets | — |
| `aws_cloudwatch_log_group.flow` | Flow-log destination, 365-day retention (audit baseline) | Small ingestion cost (REJECT-only) |
| `aws_iam_role.flow` + `aws_iam_role_policy.flow` + assume-role document | Lets the flow-logs service write to that one log group only | Least privilege |
| `aws_flow_log.this` | Logs **REJECTED** traffic only (security signal, lower volume than ALL) | Cost-conscious |
