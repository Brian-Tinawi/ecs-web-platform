# `modules/ecr/main.tf`

| Resource | Settings | Why / implication |
|---|---|---|
| `aws_ecr_repository.this` | `image_tag_mutability = IMMUTABLE` | A tag can never be silently overwritten — a deployed tag always means the same bytes (rollback/audit). Our tags are content hashes. |
| | `scan_on_push = true` | Basic CVE scan on every push (evidence captured in README) |
| | `encryption_type = KMS` | Encryption at rest with the AWS-managed key (no key fee) |
| | `force_delete = true` | Lab only: lets `terraform destroy` remove a repo that still has images. Prod: false. |
| `aws_ecr_lifecycle_policy.this` | Keep the latest 5 images, expire the rest | Storage cost control; 5 is enough to roll back |
