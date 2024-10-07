locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  aws_region  = "eu-west-1"
}
