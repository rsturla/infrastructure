terraform {
  source = "git::git@github.com:rsturla/terraform-modules.git//modules/aws/security/cloudtrail?ref=main"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  accounts    = local.common_vars.locals.accounts
  account_ids = local.common_vars.locals.account_ids

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_name = local.account_vars.locals.account_name

  account_id = local.account_ids[local.account_name]

  region_vars           = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  org_cloudtrail_bucket = local.common_vars.locals.org_cloudtrail_bucket
}

inputs = {
  is_organization_management_account = local.account_name == "management"

  # Due to a bug in the AWS provider, we cannot currently delegate organization trails to a different account
  // delegated_administrator_account_id = local.account_ids["security-tooling"]

  name                  = "org-trail"
  s3_bucket_name        = local.org_cloudtrail_bucket
  is_organization_trail = true
  create_s3_bucket      = false
}
