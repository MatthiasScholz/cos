variable "ami_id_servers" {
  description = "The ID of the AMI to be used for the nomad server nodes."
}

variable "env_name" {
  description = "name of the environment (i.e. prod)"
}

variable "stack_name" {
  description = "shortcut for this stack"
}

variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "server_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad servers into."
  type        = "list"
}

variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
}

variable "cluster_name" {
  description = "What to name the Nomad cluster and all of its associated resources"
  default     = "nomad-example"
}

variable "num_servers" {
  description = "The number of Nomad server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "instance_type_server" {
  description = "The instance type for all nomad server nodes."
  default     = "t2.micro"
}

variable "consul_cluster_tag_key" {
  description = "This variable defines the name of the tag that is used to find the consul-servers. On each nomad instance the consul-agent searches for EC2 instances tagged with this tag and having the value of consul_cluster_tag_value."
}

variable "consul_cluster_tag_value" {
  description = "This variable defines the value of the tag defined by consul_cluster_tag_key. This is used to find the consul servers (see: consul_cluster_tag_key)."
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
