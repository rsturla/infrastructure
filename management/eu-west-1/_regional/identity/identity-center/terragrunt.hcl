terraform {
  source = "git::git@github.com:rsturla/terraform-modules.git//modules/aws/identity/identity-center?ref=main"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  accounts    = local.common_vars.locals.accounts
  account_ids = local.common_vars.locals.account_ids
}

inputs = {
  sso_groups = {
    Admin    = "Administrator access to the entire AWS organization"
    ReadOnly = "Read-only access to the entire AWS organization"
  }

  permission_sets = {
    AWSAdministratorAccess = {
      description = "Administrator access to all child accounts in the AWS organization"
      session_duration = "PT1H"
      aws_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      customer_managed_policies = []
    }
    AWSReadOnlyAccess = {
      description = "Read-only access to all child accounts in the AWS organization"
      session_duration = "PT3H"
      aws_managed_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      customer_managed_policies = []
    }
  }

  account_assignments = {
    Administrator = {
      principal_name  = "Admin"
      principal_type  = "GROUP"
      permission_sets = ["AWSAdministratorAccess", "AWSReadOnlyAccess"]
      account_ids     = values(local.account_ids)
    }
    ReadOnly = {
      principal_name  = "ReadOnly"
      principal_type  = "GROUP"
      permission_sets = ["AWSReadOnlyAccess"]
      account_ids     = values(local.account_ids)
    }
  }
}
