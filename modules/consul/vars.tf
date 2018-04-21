#### Required Variables ############################################
variable "ami_id" {
  description = "The ID of the AMI to be used for the consul nodes."
}

variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "subnet_ids" {
  description = "Ids of the subnets to deploy the consul servers into."
  type        = "list"
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

variable "cluster_tag_key" {
  description = "This variable defines the name of the tag that is used to find the consul-servers. All consul-server instances will be tagged with 'consul_cluster_tag_value:consul_cluster_tag_value'."
  default     = "consul-servers"
}

variable "cluster_tag_value" {
  description = "This variable defines the value of the tag defined by consul_cluster_tag_key. All consul-server instances will be tagged with 'consul_cluster_tag_value:consul_cluster_tag_value'."
  default     = "consul-example-server"
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of cidr block from which inbound ssh traffic should be allowed."
  type        = "list"
  default     = []
}

variable "num_servers" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "instance_type" {
  description = "The instance type for all consul server nodes."
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}
