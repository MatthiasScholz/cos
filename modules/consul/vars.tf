variable "consul_ami_id" {
  description = "The ID of the AMI to be used for the consul nodes."
}

variable "env_name" {
  description = "name of the environment (i.e. prod)"
}

variable "nomad_servers_iam_role_id" {
  description = "Id of the IAM-role of the nomad servers. This is needed in order to inject a policy that grants access to consul for service-discovery."
}

variable "nomad_clients_iam_role_id" {
  description = "Id of the IAM-role of the nomad clients. This is needed in order to inject a policy that grants access to consul for service-discovery."
}

variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "consul_server_subnet_ids" {
  description = "Ids of the subnets to deploy the consul servers into."
  type        = "list"
}

variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
}

variable "stack_name" {
  description = "shortcut for this stack"
  default     = "COS"
}

variable "consul_cluster_name" {
  description = "What to name the Consul cluster and all of its associated resources"
  default     = "consul-example"
}

variable "num_consul_servers" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "instance_type" {
  description = "The instance type for all consul server nodes."
  default     = "t2.micro"
}

variable "cluster_tag_key" {
  description = "The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster."
  default     = "consul-servers"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "unique_postfix" {
  description = "A postfix to be used to generate unique resource names per deployment."
  default     = ""
}
