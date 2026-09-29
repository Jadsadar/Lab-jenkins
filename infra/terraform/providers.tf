terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Every AWS API call goes to LocalStack; the skip_* flags stop the provider from
# checking the (fake) credentials and account against real AWS.
provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    ec2 = var.aws_endpoint
    s3  = var.aws_endpoint
    sts = var.aws_endpoint
  }
}
