variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "subnet_ids" {
  description = "Ids of the subnets to deploy the alb's into."
  type        = "list"
}

variable "nomad_server_asg_name" {
  description = "Name of the AutoScalingGroup of the nomad-servers."
}

variable "env_name" {
  description = "name of the environment (i.e. prod)"
  default     = "playground"
}

variable "stack_name" {
  description = "shortcut for this stack"
  default     = "COS"
}

variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "eu-central-1"
}

variable "unique_postfix" {
  description = "A postfix to be used to generate unique resource names per deployment."
  default     = ""
}
