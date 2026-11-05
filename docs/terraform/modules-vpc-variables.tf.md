# `modules/vpc/variables.tf`

Inputs of this root/module. Each is typed and described; defaults are the cheapest safe value.

| Name | Type | Default | What it does |
|---|---|---|---|
| `name_prefix` | `string` | `—` | Prefix for resource names. |
| `vpc_cidr` | `string` | `—` | VPC CIDR (a /16). Subnets are carved into /24s with cidrsubnet(). |
| `az_count` | `number` | `2` | Number of AZs (2 = minimum for AZ-failure tolerance). |
