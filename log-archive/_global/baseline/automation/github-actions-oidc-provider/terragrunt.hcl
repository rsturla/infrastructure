include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/automation/github-actions-oidc-provider.hcl"
  expose = true
}

inputs = {}
