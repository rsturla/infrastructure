# Infrastructure

The repository housing all foundational AWS resources across my personal environment.

## Account Layout

**Management**

The AWS Organization management account.  

**Log Archive**

The AWS account which stores all security-related logs in S3 or CloudWatch.  This includes services such as CloudTrail, VPC Flow Logs etc.

**Security Tooling**

The Security Tooling account is the delegated administrator for organization-wide tooling, including Security Hub, Inspector, Guardduty etc.
Some of these tools may not be present at this moment due to budget constraints.

## Current Issues & Limitations

- GitHub Actions CI/CD will not destroy Terragrunt stacks which have been removed
- The list of AWS accounts in my environment is hidden since I wish to keep account IDs and emails private
- Due to a lack of budget, I've had to be strict about which security services to use and which to miss
