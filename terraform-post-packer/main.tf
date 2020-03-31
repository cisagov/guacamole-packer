# Default AWS provider (EC2AMICreate role in the Images account)
provider "aws" {
  region  = "us-east-1"
  profile = "cool-images-ec2amicreate"
}

# AWS provider for the Master account (OrganizationsReadOnly role)
provider "aws" {
  region  = "us-east-1"
  profile = "cool-master-organizationsreadonly"
  alias   = "master"
}

# Use aws_caller_identity with the default provider (Images account)
# so we can provide the Images account ID below
data "aws_caller_identity" "images" {
}

# ------------------------------------------------------------------------------
# Retrieve the information for all accounts in the organization.  This is used to lookup
# the Images account ID for use in the calculation of the related env account names.
# ------------------------------------------------------------------------------
data "aws_organizations_organization" "cool" {
  provider = aws.master
}

# ------------------------------------------------------------------------------
# Evaluate expressions for use throughout this configuration.
# ------------------------------------------------------------------------------
locals {
  # Find the Images account by id.
  images_account_name = [
    for x in data.aws_organizations_organization.cool.accounts :
    x.name if x.id == data.aws_caller_identity.images.account_id
  ][0]

  # Calculate what the names of the accounts that are allowed to use
  # this AMI should look like.  In this case the only accounts that
  # are allowed to use this AMI are the env* accounts of the same type
  # (production, staging, etc.) as the Images account.
  images_account_type = trim(split("(", local.images_account_name)[1], ")")
  account_name_regex  = format("^env[[:digit:]]+ \\(%s\\)$", local.images_account_type)
}

# The most-recent AMI created by cisagov/guacamole-packer
data "aws_ami" "guacamole" {
  filter {
    name = "name"
    values = [
      "guacamole-hvm-*-x86_64-ebs",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners      = [data.aws_caller_identity.images.account_id]
  most_recent = true
}

# Assign launch permissions to the AMI
module "ami_launch_permission" {
  source = "github.com/cisagov/ami-launch-permission-tf-module"

  providers = {
    aws        = aws
    aws.master = aws.master
  }

  account_name_regex = local.account_name_regex
  ami_id             = data.aws_ami.guacamole.id
}
