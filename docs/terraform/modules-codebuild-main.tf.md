# `modules/codebuild/main.tf` (ADR 001)

| Resource | Settings | Why / implication |
|---|---|---|
| `data.archive_file.src` | Zips `app/` | Source for the build; its SHA-256 (first 12 chars) becomes the image tag → fits IMMUTABLE ECR tags |
| `aws_s3_bucket.src` | account-ID suffix, `force_destroy` | Holds the source zip; destroyed with the stack |
| `..._public_access_block`, `..._server_side_encryption_configuration` (SSE-S3), `..._versioning` | All public access blocked, AES256, versioned | Standard bucket hygiene |
| `aws_s3_object.src` | Uploads the zip | CodeBuild source |
| `aws_cloudwatch_log_group.build` | 365d retention | Build logs |
| `aws_iam_role.build` + policy doc + `aws_iam_role_policy.build` | Logs to its group only; read the one bucket; ECR push to **this repo only**; `GetAuthorizationToken` on `*` (AWS requires it) | Least privilege |
| `aws_codebuild_project.this` | `BUILD_GENERAL1_SMALL` (cheapest), `standard:7.0`, `privileged_mode = true` (needed for docker-in-docker; checkov skip documented), 15-min timeout; inline buildspec logs in to ECR, builds, pushes | ~$0.005/min; a build is ~1–2 min |
| `terraform_data.build` | `local-exec` starts the build and polls until SUCCEEDED, failing apply otherwise | Guarantees the image exists before ECS creates tasks; re-runs only when the source hash changes |
