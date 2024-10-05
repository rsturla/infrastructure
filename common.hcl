locals {
  default_region = "eu-west-1"
  state_region   = "eu-west-1"

  accounts = jsondecode(file("_private/accounts.json")).accounts
  account_ids = {
    for key, account_info in local.accounts : key => account_info.id
  }

  management_account = {
    for name, account_info in local.accounts : name => account_info
    if account_info.type == "management"
  }
  governance_member_accounts = {
    for name, account_info in local.accounts : name => account_info
    if account_info.type == "governance"
  }
  workload_member_accounts = {
    for name, account_info in local.accounts : name => account_info
    if account_info.type == "workload"
  }
  sandbox_member_accounts = {
    for name, account_info in local.accounts : name => account_info
    if account_info.type == "sandbox"
  }

  repository = "rsturla/infrastructure"

  mgmt_vpc_cidrs    = {}
  app_vpc_cidrs     = {}
  sandbox_vpc_cidrs = {}

  org_units = {
    root       = "r-6hmd"
    governance = "ou-6hmd-c4ut55g8"
    sandbox    = "ou-6hmd-68z95dnm"
    workload   = "ou-6hmd-ubrh8ojk"
  }
}
