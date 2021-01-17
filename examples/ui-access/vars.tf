variable "deploy_profile" {
  description = "Specify the local AWS profile configuration to use."
}

variable "ssh_key_name" {
  description = "Name of the SSH instance key to be used."
  default = "kp-us-east-1-playground-instancekey"
}

variable "aws_region" {
  description = "This region should be fixed to the default value, since internally a certain AMI ID is used."
  default = "us-east-1"
}

