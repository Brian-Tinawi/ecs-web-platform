output "image_tag" {
  description = "Content-addressed image tag that CodeBuild pushed."
  value       = local.image_tag
}

output "build_done" {
  description = "Changes when the image build completes (use to order ECS after the push)."
  value       = terraform_data.build.id
}

output "project_name" {
  description = "CodeBuild project name."
  value       = aws_codebuild_project.this.name
}
