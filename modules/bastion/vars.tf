#### Required Variables ############################################
variable "ami_id" {
  description = "The ID of the AMI to be used for the consul nodes."
}

variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "subnet_id" {
  description = "Id of the subnets to deploy the bastion instance to."
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
}

#### Optional Variables ############################################
variable "env_name" {
  description = "name of the environment (i.e. prod)"
  default     = "playground"
}

variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "eu-central-1"
}

variable "stack_name" {
  description = "shortcut for this stack"
  default     = "COS"
}

variable "instance_type" {
  description = "The instance type for all consul server nodes."
  default     = "t2.micro"
}

variable "unique_postfix" {
  description = "A postfix to be used to generate unique resource names per deployment."
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "Map for cidr blocks that should get access to the bastion. The format is name:cidr-block. I.e. 'my_cidr'='90.250.75.79/32'"
  type        = "map"

  default = {
    "all" = "0.0.0.0/0"
  }
}
