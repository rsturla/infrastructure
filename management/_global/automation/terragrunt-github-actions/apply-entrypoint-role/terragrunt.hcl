terraform {
  source = "git::git@github.com:rsturla/terraform-modules.git//modules/aws/identity/github-actions-role?ref=main"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  accounts    = local.common_vars.locals.accounts

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_ids  = local.common_vars.locals.account_ids
  account_name = local.account_vars.locals.account_name

  repository = local.common_vars.locals.repository
  org_id     = local.common_vars.locals.org_id
}


inputs = {
  name        = "terragrunt-apply-entrypoint-role"
  repository  = local.repository
  git_pattern = "environment:deploy"

  policy_statements = {
    AssumeTerragruntApplyRole = {
      effect = "Allow"
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]
      resources = [
        "arn:aws:iam::*:role/terragrunt-apply-role"
      ]
      condition = {
        IsInOrg = {
          test     = "StringEquals"
          variable = "aws:PrincipalOrgID"
          values   = [local.org_id]
        }
      }
    }
  }
}
