#### Required Variables ############################################
variable "ami_id" {
  description = "The ID of the AMI to be used for the nomad server nodes."
}

variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "subnet_ids" {
  description = "Ids of the subnets to deploy the nomad servers into."
  type        = "list"
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
  description = "The instance type for all nomad server nodes."
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "unique_postfix" {
  description = "A postfix to be used to generate unique resource names per deployment."
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of cidr block from which inbound ssh traffic should be allowed."
  type        = "list"
  default     = []
}

variable "datacenter_name" {
  description = "The name for the nomad-servers (i.e. leader)."
  default     = "leader"
}

variable "node_scaling_cfg" {
  description = "Scaling configuration for the nomad servers."
  type        = "map"

  default = {
    "min"              = 3
    "max"              = 3
    "desired_capacity" = 3
  }
}
