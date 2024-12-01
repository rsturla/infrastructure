terraform {
  source = "git::git@github.com:rsturla/terraform-modules.git//modules/aws/cost-control/budgets?ref=main"
}

# Include the root `terragrunt.hcl` configuration, which has settings common across all environments & components.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  sns_topic_name = "budgets"
  notifications = [
    {
      comparison_operator = "GREATER_THAN"
      threshold           = 80
      threshold_type      = "PERCENTAGE"
      notification_type   = "ACTUAL"
    },
    {
      comparison_operator = "GREATER_THAN"
      threshold           = 100
      threshold_type      = "PERCENTAGE"
      notification_type   = "FORECASTED"
    }
  ]

  budgets = {
    overall = {
      budget_type  = "COST"
      limit_amount = 20
      limit_unit   = "USD"
      time_unit    = "MONTHLY"
    }
  }
}
