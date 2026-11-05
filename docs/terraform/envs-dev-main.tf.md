# `envs/dev/main.tf` (and `envs/prod/main.tf`, identical wiring)
- `locals.tags`: the six mandatory tags (project, environment, owner=brian, managed-by, cost-center, ttl) feeding provider `default_tags`.
- `locals.name`: `<project>-<env>` prefix for every resource name.
- `module.vpc` → network; `module.ecr` → repository; `module.codebuild` → builds and pushes the image; `module.ecs_service` → ALB + cluster + service. The service image is `repo:<hash tag>` and `depends_on` the build so ECS never starts before the image exists.
- `aws_budgets_budget.project`: monthly cost budget ($10) filtered by the `project` tag; emails at 80% actual and 100% forecast. Cost safety net.
