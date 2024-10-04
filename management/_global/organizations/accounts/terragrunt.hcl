terraform {
  source = "git::git@github.com:rsturla/terraform-modules.git//modules/aws/security/organizations?ref=main"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  accounts    = local.common_vars.locals.accounts

  member_accounts = {
    for account_name, account_info in local.accounts : account_name => account_info
    if account_info.type != "management"
  }
}

inputs = {
  organizations_aws_service_access_principals = [
    "member.org.stacksets.cloudformation.amazonaws.com",
  ]

  child_accounts = {
    for account_name, account_info in local.member_accounts : account_name => {
      email             = account_info.email
      close_on_deletion = true
    }
  }
}
