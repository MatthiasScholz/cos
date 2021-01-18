
terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # FIXME: Newer versions not working: https://github.com/hashicorp/terraform-provider-aws/issues/14085
      version = "2.63.0"
    }
  }
}
