variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "subnet_ids" {
  description = "Ids of the subnets to deploy the alb's into."
  type        = "list"
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

variable "nomad_server_asg_name" {
  description = "Name of the AutoScalingGroup of the nomad-servers."
}

variable "nomad_ui_port" {
  description = "The port to access the nomad ui."
  default     = 4646
}

variable "consul_server_asg_name" {
  description = "Name of the AutoScalingGroup of the consul-servers."
}

variable "consul_ui_port" {
  description = "The port to access the consul ui."
  default     = 8500
}

variable "allowed_cidr_blocks_for_ui_alb" {
  type = "map"

  default = {
    "pcc_dev" = "80.146.215.90/32"
    "thomas"  = "95.90.215.115/32"
  }
}
