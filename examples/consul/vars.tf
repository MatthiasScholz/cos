variable "deploy_profile" {
  description = "Specify the local AWS profile configuration to use."
}

variable "ami_id" {
  description = "Name of the AMI used to run this example."
  default = "ami-0c2d89864d854f92c" # 2020-12-25
}

variable "aws_region" {
  description = "AWS Region the module should deployed to."
  default = "us-east-1"
}
