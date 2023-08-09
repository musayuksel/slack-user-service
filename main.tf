terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
      #   hashicorp/aws" provider with a version greater than or equal to 4.16
    }
  }

  required_version = ">= 1.2.0"
  #   Terraform version 1.2.0 or higher.
}
# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
  #   The AWS region to create resources in.
}

# Create a VPC
resource "aws_cognito_user_pool" "slack_user_pool" {
  name = "slack_users"
  # AWS Cognito User Pool resource named "slack_users"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  #  The username attributes and auto-verified attributes is going to be the email address.

  password_policy {
    minimum_length    = 8
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }
  #   The password policy is going to be a minimum of 8 characters and no other requirements.


  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "Your verification code is {####}."
    email_subject        = "Your verification code"
    #  The verification message template is going to be a default email option of CONFIRM_WITH_CODE. {####} is going to be the verification code.

  }

  schema {
    name = "email"
    # The schema is going to be the email address.
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 0
      max_length = 256
    }
  }



}

resource "aws_cognito_user_pool_client" "slack_client" {
  name                          = "slack_client"
  user_pool_id                  = aws_cognito_user_pool.slack_user_pool.id
  generate_secret               = false
  refresh_token_validity        = 90
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  #  The user pool client is going to be named slack_client and Refers to the ID of the AWS Cognito User Pool resource created earlier.
  #  aws_cognito_user_pool.slack_user_pool.id syntax retrieves the ID of the "slack_user_pool" resource.  
  #   The refresh token validity is going to be 90 days.

}

resource "aws_cognito_user_pool_domain" "slack_domain" {
  domain       = "slack"
  user_pool_id = aws_cognito_user_pool.slack_user_pool.id
  #  The domain is going to be slack and Refers to the ID of the AWS Cognito User Pool resource created earlier.
}
