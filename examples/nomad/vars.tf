variable "deploy_profile" {
  description = "Specify the local AWS profile configuration to use."
}

variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "us-east-1"
}

variable "nomad_ami_id" {
  description = "The ID of the AMI to be used for the nomad nodes."
  default     = "ami-a23feadf"
}

variable "stack_name" {
  description = "shortcut for this stack"
  default     = "COS"
}

variable "env_name" {
  description = "name of the environment (i.e. prod)"
  default     = "playground"
}
