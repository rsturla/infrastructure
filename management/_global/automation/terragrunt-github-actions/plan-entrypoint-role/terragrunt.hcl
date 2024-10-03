terraform {
  source = "git::git@github.com:rsturla/terraform-modules.git//modules/aws/identity/github-actions-role?ref=github-actions-module-outputs"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  accounts    = local.common_vars.locals.accounts

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_ids = local.common_vars.locals.account_ids
  account_name = local.account_vars.locals.account_name

  repository = local.common_vars.locals.repository
}

inputs = {
  name        = "terragrunt-plan-entrypoint-role"
  repository  = local.repository
  git_pattern = "environment:plan"

  policy_statements = {
    AssumeTerragruntPlanRole = {
      effect    = "Allow"
      actions   = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]
      resources = [
        for account in local.accounts : "arn:aws:iam::${local.account_ids[local.account_name]}:role/terragrunt-plan-role"
      ]
    }
  }
}
