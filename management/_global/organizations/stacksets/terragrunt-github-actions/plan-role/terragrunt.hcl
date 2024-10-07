terraform {
  source = "git::git@github.com:rsturla/terraform-modules.git//modules/aws/security/cloudformation-stackset?ref=main"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "plan_entrypoint_role" {
  config_path = "${get_terragrunt_dir()}/../../../../automation/terragrunt-github-actions/plan-entrypoint-role"

  mock_outputs = {
    arn = "arn:aws:iam::${local.account_ids["management"]}:role/terragrunt-plan-entrypoint-role"
  }
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  accounts    = local.common_vars.locals.accounts
  account_ids = local.common_vars.locals.account_ids

  org_units = local.common_vars.locals.org_units

  state_region        = local.common_vars.locals.state_region
  state_bucket_suffix = "-${replace(local.state_region, "-", "")}-rsturla"
}

inputs = {
  name        = "TerragruntPlanRoleStackSet"
  description = "StackSet for Terragrunt GitHub Actions Plan Role"

  template_body = file("${find_in_parent_folders("_envcommon")}/cloudformation/terragrunt-github-actions-plan-role.yml")
  capabilities  = ["CAPABILITY_NAMED_IAM"]

  target_org_units = [local.org_units["root"]]

  parameters = {
    ExternalAccountRoleArn          = dependency.plan_entrypoint_role.outputs.arn
    TerragruntRemoteStateBucketName = "tfstate-*${local.state_bucket_suffix}"
    TerragruntStateLockTableName    = "opentofu-locks"
  }
}
