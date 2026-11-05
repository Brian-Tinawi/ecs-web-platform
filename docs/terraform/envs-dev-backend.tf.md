# `envs/dev/backend.tf`

S3 remote state in the shared bootstrap bucket (`tfstate-portfolio-…-us-west-2`), key `projects/ecs-web-platform/dev.tfstate`, `encrypt = true` (SSE at rest), `use_lockfile = true` (S3-native locking; no DynamoDB table to pay for). State is never committed.
