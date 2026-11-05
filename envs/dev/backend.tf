# Remote state from ~/cloud-portfolio/bootstrap (terraform -chdir=~/cloud-portfolio/bootstrap output).
# S3 native locking (use_lockfile) — no DynamoDB table needed.
terraform {
  backend "s3" {
    bucket       = "tfstate-portfolio-884725728491-us-west-2"
    key          = "projects/ecs-web-platform/dev.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}

