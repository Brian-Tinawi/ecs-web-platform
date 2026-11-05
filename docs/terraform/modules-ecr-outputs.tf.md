# `modules/ecr/outputs.tf`

Outputs. All non-sensitive; the smoke tests and evidence scripts read them with `terraform output`.

| Name | What it exposes |
|---|---|
| `repository_url` | Repository URL (no tag). |
| `repository_arn` | Repository ARN. |
| `repository_name` | Repository name. |
