# Evidence

Proof the project works, captured during short-lived deployments (deploy → smoke test → capture → destroy).

| File | What it shows |
|---|---|
| `smoke-<env>.txt` | Redacted smoke-test output (`make verify`) |
| `apply-<env>.txt` | Redacted `terraform apply` summary |
| `*.gif` | Recording of the key behaviour (failover / autoscaling / remediation …) |
| `runs.md` | Every deployment: date, TTL, estimated vs actual cost, smoke result |
| `LAST_VERIFIED.md` | Most recent successful verification |

All account/subscription/tenant IDs, IPs and emails are redacted.
