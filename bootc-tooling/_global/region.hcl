locals {
  common_vars        = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars       = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_name_short = local.account_vars.locals.account_name_short

  aws_region = "eu-west-1"

  bucket_suffix = "-${local.account_name_short}-${replace(local.aws_region, "-", "")}-rsturla"
}
