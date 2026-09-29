# Remote state: S3 bucket on LocalStack (created once by hand, versioning enabled).
# Nothing about state is ever committed; credentials come from AWS_ACCESS_KEY_ID /
# AWS_SECRET_ACCESS_KEY, which the pipeline takes from the localstack-aws credential.
terraform {
  backend "s3" {
    bucket       = "taskflow-tfstate"
    key          = "lab08/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true # S3-native state locking (Terraform 1.10+)

    endpoints                   = { s3 = "http://localstack:4566" }
    use_path_style              = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}
