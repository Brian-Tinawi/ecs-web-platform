# `modules/codebuild/variables.tf`

Inputs of this root/module. Each is typed and described; defaults are the cheapest safe value.

| Name | Type | Default | What it does |
|---|---|---|---|
| `name_prefix` | `string` | `—` | Prefix for resource names. |
| `app_dir` | `string` | `—` | Path to the app directory (Dockerfile + code) to build. |
| `ecr_repository_url` | `string` | `—` | ECR repository URL to push to. |
| `ecr_repository_arn` | `string` | `—` | ECR repository ARN (scopes the push permission). |
| `region` | `string` | `—` | AWS region. |
