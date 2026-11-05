# `envs/dev/versions.tf`

Pins Terraform (`>= 1.17.0, < 2.0.0`) and every provider with `~>` so runs are reproducible; a provider major bump needs a deliberate change. No cost or security impact; supply-chain control.

`hashicorp/archive ~> 2.7` zips the `app/` directory so CodeBuild can use it as source and so the zip hash can become the image tag.
