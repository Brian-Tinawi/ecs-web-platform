# Credentials: locally AWS_PROFILE=portfolio (IAM Identity Center SSO); in CI, GitHub OIDC.
provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

# provider "azurerm" {
#   features {}
#   subscription_id = var.subscription_id
# }
