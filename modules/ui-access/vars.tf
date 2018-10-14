#### Required Variables ############################################
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

variable "consul_server_asg_name" {
  description = "Name of the AutoScalingGroup of the consul-servers."
}

variable "fabio_server_asg_name" {
  description = "Name of the AutoScalingGroup of the fabio-servers."
}

#### Optional Variables ############################################
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

variable "nomad_ui_port" {
  description = "The port to access the nomad ui."
  default     = 4646
}

variable "consul_ui_port" {
  description = "The port to access the consul ui."
  default     = 8500
}

variable "fabio_ui_port" {
  description = "The port to access the fabio ui."
  default     = 9998
}

variable "allowed_cidr_blocks_for_ui_alb" {
  description = "Map for cidr blocks that should get access over alb. The format is name:cidr-block. I.e. 'my_cidr'='90.250.75.79/32'"
  type        = "map"

  default = {
    "all" = "0.0.0.0/0"
  }
}

variable "unique_postfix" {
  description = "A postfix that will be used in names to avoid collisions (mainly used for name tags)."
  default     = ""
}

variable "ui_alb_https_listener_cert_arn" {
  description = "ARN of the certificate that should be used to set up the https endpoint for the ui-alb's. If not provided, a http enpoint will be created."
  default     = ""
}

variable "ui_alb_use_https_listener" {
  description = "If true, the https endpoint for the ui-albs will be created instead of the http one. Precondition for this is that ui_alb_https_listener_cert_arn is set apropriately."
  default     = false
}
