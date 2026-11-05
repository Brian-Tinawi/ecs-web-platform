# `envs/prod/variables.tf`

Inputs of this root/module. Each is typed and described; defaults are the cheapest safe value.

| Name | Type | Default | What it does |
|---|---|---|---|
| `project` | `string` | `—` | Project slug, used in names and tags. |
| `environment` | `string` | `—` | Environment name (dev or prod). |
| `region` | `string` | `"us-west-2"` | Primary region. |
| `cost_center` | `string` | `"portfolio-lab"` | Cost-center tag value. |
| `ttl` | `string` | `—` | ISO-8601 UTC expiry for every resource (set by `make plan`, default now+4h). The TTL reaper destroys expired envs. |
| `budget_email` | `string` | `—` | Email for the per-project budget alert. |
| `monthly_budget_usd` | `number` | `10` | Per-project monthly budget. |
| `vpc_cidr` | `string` | `—` | VPC /16 CIDR. |
| `min_tasks` | `number` | `2` | Minimum (and initial) ECS task count. |
| `max_tasks` | `number` | `4` | Maximum ECS task count (autoscaling). |

`ttl` is validated with a regex: every resource carries an ISO-8601 UTC expiry so the TTL reaper can delete forgotten stacks (cost control).
