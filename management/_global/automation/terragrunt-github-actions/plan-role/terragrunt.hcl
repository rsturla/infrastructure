terraform {
  source = "git::git@github.com:rsturla/terraform-modules.git//modules/aws/misc/cloudformation-stack?ref=github-actions-module-outputs"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "plan_entrypoint_role" {
  config_path = "${get_terragrunt_dir()}/../plan-entrypoint-role"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  accounts    = local.common_vars.locals.accounts
  account_ids = local.common_vars.locals.account_ids

  state_region        = local.common_vars.locals.state_region
  state_bucket_suffix = "-${replace(local.state_region, "-", "")}-rsturla"
}

inputs = {
  name          = "TerragruntPlanRoleStack"
  template_body = file("${find_in_parent_folders("_envcommon")}/cloudformation/terragrunt-github-actions-plan-role.yml")
  capabilities  = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    ExternalAccountRoleArn          = "arn:aws:iam::${local.account_ids["management"]}:role/terragrunt-plan-entrypoint-role"
    TerragruntRemoteStateBucketName = "tfstate-*${local.state_bucket_suffix}"
  }

  assume_policy_statements = {
    Deploy = {
      effect = "Allow"
      actions = [
        "iam:*",
      ]
      resources = ["*"]
    }
  }
}
