---
project: ecs-web-platform
date: 2026-11-05
services_chosen: [Elastic Load Balancing]
services_rejected: [HTTPS in the lab]
---
# ADR 005 — HTTP-only listener in the lab
No registered domain or ACM certificate exists in the lab account, so the ALB listens on :80. Production adds an ACM cert, a :443 listener (TLS 1.3 policy), an HTTP→HTTPS redirect, ALB access logs, and Cloudflare/WAF in front (see README "Production additions"). The related checkov findings are skipped with written justification in `.checkov.yaml`.
