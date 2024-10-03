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

  repository = local.common_vars.locals.repository
}

inputs = {
  name        = "terragrunt-apply-role"
  repository  = local.repository
  git_pattern = "refs/heads/main"

  create_openid_connect_provider = true

  # TODO: Restrict this to the minimum required permissions - should be able to manage infrastructure, not data.
  policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
