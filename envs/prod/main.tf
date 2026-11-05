locals {
  name = "${var.project}-${var.environment}"

  tags = {
    project     = var.project
    environment = var.environment
    owner       = "brian"
    managed-by  = "terraform"
    cost-center = var.cost_center
    ttl         = var.ttl
  }
}

module "vpc" {
  source      = "../../modules/vpc"
  name_prefix = local.name
  vpc_cidr    = var.vpc_cidr
}

module "ecr" {
  source = "../../modules/ecr"
  name   = local.name
}

module "codebuild" {
  source             = "../../modules/codebuild"
  name_prefix        = local.name
  app_dir            = "${path.root}/../../app"
  ecr_repository_url = module.ecr.repository_url
  ecr_repository_arn = module.ecr.repository_arn
  region             = var.region
}

module "ecs_service" {
  source             = "../../modules/ecs-service"
  name_prefix        = local.name
  region             = var.region
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  image              = "${module.ecr.repository_url}:${module.codebuild.image_tag}"
  desired_count      = var.min_tasks
  min_count          = var.min_tasks
  max_count          = var.max_tasks

  depends_on = [module.codebuild] # image must be pushed before ECS starts tasks
}

# Every project includes a cost alert (filtered to this project's tag).
resource "aws_budgets_budget" "project" {
  name         = "${var.project}-${var.environment}-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "TagKeyValue"
    values = [format("user:project$%s", var.project)]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget_email]
  }
}
