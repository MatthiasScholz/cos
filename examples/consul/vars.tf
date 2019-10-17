variable "deploy_profile" {
  description = "Specify the local AWS profile configuration to use."
}

variable "ssh_key_name" {
  description = "Name of the SSH instance key to be used."
  default = "kp-us-east-1-playground-instancekey"
}

variable "ami_id" {
  description = "Name of the AMI used to run this example."
  default = "ami-a23feadf"
}

variable "aws_region" {
  description = "AWS Region the module should deployed to."
  default = "us-east-1"
}
