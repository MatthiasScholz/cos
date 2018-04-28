#### Required Variables ############################################
variable "ami_id" {
  description = "The ID of the AMI to be used for the nomad nodes."
}

variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "server_sg_id" {
  description = "The id of the nomad-server security group. This is needed to grant access to the datacenter nodes."
}

variable "consul_cluster_tag_key" {
  description = "This variable defines the name of the tag that is used to find the consul-servers. On each nomad instance the consul-agent searches for EC2 instances tagged with this tag and having the value of consul_cluster_tag_value."
}

variable "consul_cluster_tag_value" {
  description = "This variable defines the value of the tag defined by consul_cluster_tag_key. This is used to find the consul servers (see: consul_cluster_tag_key)."
}

variable "consul_cluster_security_group_id" {
  description = "Id of the security-group of the consul server."
}

variable "subnet_ids" {
  description = "Subnet id's for nomad client nodes providing this data-center."
  type        = "list"
}

#### Optional Variables ############################################
variable "alb_ingress_arn" {
  description = "The arn of the alb for ingress data. If not specified, no alb-attachment will be created to grant ingress access to the data-center nodes."
  default     = ""
}

variable "attach_ingress_alb" {
  description = "If true, the datacenter nodes will be attached to the ingress alb. Therfore the variable alb_ingress_arn has to be set."
  default     = false
}

variable "ingress_controller_port" {
  description = "The port of the ingress controller (i.e. fabio)."
  default     = 9999
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

variable "datacenter_name" {
  description = "The name of the datacenter (i.e. backoffice)."
  default     = "dc-example"
}

variable "node_scaling_cfg" {
  description = "Scaling configuration for the nomad nodes to deploy for this datacenter. You can deploy as many as you need to run your jobs."
  type        = "map"

  default = {
    "min"              = 1
    "max"              = 1
    "desired_capacity" = 1
  }
}

variable "instance_type" {
  description = "The instance type for nomad nodes."
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of cidr block from which inbound ssh traffic should be allowed for this datacenter."
  type        = "list"
  default     = []
}

variable "unique_postfix" {
  description = "A postfix that will be used in names to avoid collisions (mainly used for name tags)."
  default     = ""
}
