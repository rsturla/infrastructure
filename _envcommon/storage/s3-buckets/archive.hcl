terraform {
  source = "git::git@github.com:rsturla/terraform-modules.git//modules/aws/data-storage/s3-private-bucket?ref=main"
}

locals {
  region_vars   = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  bucket_suffix = local.region_vars.locals.bucket_suffix
}

inputs = {
  name = "archive${local.bucket_suffix}"
}
