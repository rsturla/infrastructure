#!/usr/bin/env bash

# Replace the string <account_id> with the AWS account ID from AWS CLI
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
# Read the config.yml.tmpl file and replace the string <account_id> with the AWS account ID
# Store the output in config.yml
sed "s/<account_id>/$ACCOUNT_ID/g" config.yml.tmpl > config.yml

# Run aws-nuke with the config.yml file in dry-run mode
aws-nuke nuke -c ./config.yml --no-alias-check --no-prompt

# Run aws-nuke with the config.yml file in destructive mode
aws-nuke nuke -c ./config.yml --no-alias-check --no-dry-run
