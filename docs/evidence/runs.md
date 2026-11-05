# Deployment runs

Every deployment is temporary: deploy → smoke test → capture evidence → destroy.
Estimated cost = Infracost hourly estimate × TTL hours. Actual cost comes from the billing APIs
(filtered by the `project` tag) once data lands (24–48h) — `~/cloud-portfolio/scripts/actual-cost.sh`.

| Date (UTC) | Env | Applied | TTL h | Est. $/hr | Est. $/deployment | Actual $ | Smoke tests |
|---|---|---|---|---|---|---|---|
| 2026-11-05 | dev | 2026-11-05T06:41:07Z | 4 | 0.0926 | 0.37 | pending | pass |
