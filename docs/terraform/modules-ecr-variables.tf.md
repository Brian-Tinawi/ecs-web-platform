# `modules/ecr/variables.tf`

Inputs of this root/module. Each is typed and described; defaults are the cheapest safe value.

| Name | Type | Default | What it does |
|---|---|---|---|
| `name` | `string` | `—` | Repository name. |
| `keep_images` | `number` | `5` | Number of images kept by the lifecycle policy. |
