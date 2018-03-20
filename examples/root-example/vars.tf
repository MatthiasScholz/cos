variable "deploy_profile" {
  description = "name of profile in ~/.aws/credentials file which should be used for deploying this infra"
  default     = "home"
}

variable "aws_region" {
  description = "region this stack should be applied to"
  default     = "eu-central-1"
}
