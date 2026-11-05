# `envs/dev/providers.tf`

AWS provider with `default_tags` = `local.tags`, so every resource gets project, environment, owner, managed-by, cost-center and ttl automatically. No profile or keys in code: locally `AWS_PROFILE=portfolio` (SSO), in CI GitHub OIDC.
