locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  account_name       = local.account_vars.locals.account_name
  account_name_short = local.account_vars.locals.account_name_short
  account_id         = local.common_vars.locals.account_ids[local.account_name]
  aws_region         = local.region_vars.locals.aws_region
  state_region       = local.common_vars.locals.state_region

  state_bucket_suffix = "-${local.account_name_short}-${replace(local.state_region, "-", "")}-rsturla"
  state_bucket        = lower("tfstate${local.state_bucket_suffix}")
  state_logs_bucket   = lower("tfstate-logs${local.state_bucket_suffix}")

  default_tags = {
    Repository  = local.common_vars.locals.repository
    ProjectPath = get_path_from_repo_root()
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<-EOF
    provider "aws" {
      region = "${local.aws_region}"

      # Only these AWS Account IDs may be operated on by this template
      allowed_account_ids = ["${local.account_id}"]

      default_tags {
        tags = ${jsonencode(local.default_tags)}
      }
    }
  EOF
}

generate "provider_version" {
  path      = "provider_version_override.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<-EOF
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = ">= 4.0"
        }
      }
    }
  EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt                   = true
    bucket                    = local.state_bucket
    bucket_sse_algorithm      = "AES256"
    key                       = "${path_relative_to_include()}/terraform.tfstate"
    region                    = local.state_region
    dynamodb_table            = "opentofu-locks"
    accesslogging_bucket_name = local.state_logs_bucket
    accesslogging_bucket_tags = local.default_tags
    s3_bucket_tags            = local.default_tags
    dynamodb_table_tags       = local.default_tags
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {
  aws_region     = local.aws_region
}
