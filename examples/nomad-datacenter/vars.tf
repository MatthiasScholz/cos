variable "deploy_profile" {
  description = "Specify the local AWS profile configuration to use."
}

variable "ami_id" {
  description = "Id of the AMI for the nomad and consul nodes."
  default     = "ami-09118e4b58586b75d"
}

variable "aws_region" {
  description = "Dummy to make use of generic terraform configuration in tests."
  default = "us-east-1"
}
