# Session log

Newest first. 3–6 bullets per entry: what we did, what changed, what broke and how we fixed it.

## 2026-11-05 — autonomous build of ecs-web-platform
- Docker absent → CodeBuild builds/pushes the image from Terraform (ADR 001); 4 modules, 55 resources, dev deployed (~$0.09/h).
- Smoke + failure tests: 10/10 pass; stop 1 task 0/67 probes failed, lose a whole AZ 0/77 failed; harness bugs found and fixed (JMESPath key, autoscaling override, drain timing).
- Evidence/screenshots captured (Playwright, CloudWatch widget images, freeze); dev destroyed and verified empty.
- Docs: README (DR design, Route 53 Alias vs CNAME, Cloudflare), INTERVIEW_PREP, RESUME, 8 ADRs, per-.tf docs.
- Not done: bootstrap OIDC mapping (needs Brian), Azure DevOps pipeline execution (by request).
