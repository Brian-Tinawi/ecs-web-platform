# Builds + pushes the container image in AWS (no local Docker needed — ADR 001).
data "aws_caller_identity" "current" {}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = var.app_dir
  output_path = "${path.module}/.src.zip"
}

locals {
  image_tag = substr(data.archive_file.src.output_sha256, 0, 12) # content-addressed: IMMUTABLE ECR tags stay valid
}

resource "aws_s3_bucket" "src" {
  bucket        = "${var.name_prefix}-build-src-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "src" {
  bucket                  = aws_s3_bucket.src.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "src" {
  bucket = aws_s3_bucket.src.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "src" {
  bucket = aws_s3_bucket.src.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "src" {
  bucket = aws_s3_bucket.src.id
  key    = "src-${local.image_tag}.zip"
  source = data.archive_file.src.output_path
  etag   = data.archive_file.src.output_md5
}

resource "aws_cloudwatch_log_group" "build" {
  name              = "/codebuild/${var.name_prefix}"
  retention_in_days = 365
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "build" {
  name               = "${var.name_prefix}-codebuild"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "build" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.build.arn}:*"]
  }
  statement {
    actions   = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${aws_s3_bucket.src.arn}/*"]
  }
  statement {
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.src.arn]
  }
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"] # this API does not support resource-level scoping
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability", "ecr:InitiateLayerUpload", "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload", "ecr:PutImage", "ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer",
    ]
    resources = [var.ecr_repository_arn]
  }
}

resource "aws_iam_role_policy" "build" {
  name   = "build-and-push"
  role   = aws_iam_role.build.id
  policy = data.aws_iam_policy_document.build.json
}

resource "aws_codebuild_project" "this" {
  name           = "${var.name_prefix}-image"
  service_role   = aws_iam_role.build.arn
  build_timeout  = 15
  encryption_key = "alias/aws/s3"

  source {
    type     = "S3"
    location = "${aws_s3_bucket.src.id}/${aws_s3_object.src.key}"
    buildspec = yamlencode({
      version = "0.2"
      phases = {
        pre_build = { commands = [
          "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPO_URL",
        ] }
        build = { commands = [
          "docker build --build-arg APP_VERSION=$IMAGE_TAG -t $REPO_URL:$IMAGE_TAG .",
          "docker push $REPO_URL:$IMAGE_TAG",
        ] }
      }
    })
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true # required for docker build inside CodeBuild
    environment_variable {
      name  = "REPO_URL"
      value = var.ecr_repository_url
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = local.image_tag
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.build.name
    }
  }
}

# Run the build during apply and block until the image is in ECR (ECS needs it to exist).
resource "terraform_data" "build" {
  triggers_replace = [local.image_tag, aws_codebuild_project.this.id]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      id=$(aws codebuild start-build --region ${var.region} --project-name ${aws_codebuild_project.this.name} --query build.id --output text)
      for i in $(seq 1 90); do
        s=$(aws codebuild batch-get-builds --region ${var.region} --ids "$id" --query 'builds[0].buildStatus' --output text)
        [ "$s" = "IN_PROGRESS" ] || break
        sleep 10
      done
      echo "CodeBuild $s"; [ "$s" = "SUCCEEDED" ]
    EOT
  }

  depends_on = [aws_iam_role_policy.build]
}
