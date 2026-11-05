# `modules/codebuild/outputs.tf`

Outputs. All non-sensitive; the smoke tests and evidence scripts read them with `terraform output`.

| Name | What it exposes |
|---|---|
| `image_tag` | Content-addressed image tag that CodeBuild pushed. |
| `build_done` | Changes when the image build completes (use to order ECS after the push). |
| `project_name` | CodeBuild project name. |
