terraform {
  source = "git::git@github.com:rsturla/terraform-modules.git//modules/aws/security/cloudtrail/bucket?ref=main"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  accounts    = local.common_vars.locals.accounts
  account_ids = local.common_vars.locals.account_ids

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_ids[local.account_name]

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region

  bucket_suffix      = local.region_vars.locals.bucket_suffix
  org_cloudtrail_arn = local.common_vars.locals.org_cloudtrail_arn
}

inputs = {
  bucket_name    = "cloudtrail${local.bucket_suffix}"
  cloudtrail_arn = local.org_cloudtrail_arn
}
