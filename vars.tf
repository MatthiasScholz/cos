variable "aws_region" {
  description = "region this stack should be applied to"
}

variable "nomad_ami_id_servers" {
  description = "The ID of the AMI to be used for the nomad server nodes."
}

variable "nomad_ami_id_clients" {
  description = "The ID of the AMI to be used for the nomad clientnodes."
}

variable "consul_ami_id" {
  description = "The ID of the AMI to be used for the consul nodes."
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "env_name" {
  description = "Name of the environment (i.e. prod)."
}

variable "unique_postfix" {
  description = "A postfix to be used to generate unique resource names per deployment."
  default     = ""
}

variable "nomad_cluster_name" {
  description = "What to name the Nomad cluster and all of its associated resources."
  default     = "nomad-example"
}

variable "consul_cluster_name" {
  description = "What to name the Consul cluster and all of its associated resources."
  default     = "consul-example"
}

variable "nomad_num_servers" {
  description = "The number of Nomad server nodes to deploy. You can deploy as many as you need to run your jobs."
  default     = 3
}

variable "nomad_num_clients" {
  description = "The number of Nomad client nodes to deploy. You can deploy as many as you need to run your jobs."
  default     = 3
}

variable "instance_type_server" {
  description = "The instance type for all nomad and consul server nodes."
  default     = "t2.micro"
}

variable "instance_type_client" {
  description = "The instance type for all nomad client nodes."
  default     = "t2.micro"
}

variable "alb_public_services_arn" {
  description = "The arn of the alb for public-services access."
}

variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "nomad_server_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad servers into."
  type        = "list"
}

variable "consul_server_subnet_ids" {
  description = "Ids of the subnets to deploy the consul servers into."
  type        = "list"
}

variable "alb_subnet_ids" {
  description = "Ids of the subnets to deploy the alb's into."
  type        = "list"
}

variable "stack_name" {
  description = "Shortcut for this stack."
  default     = "COS"
}

variable "consul_num_servers" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "consul_instance_type" {
  description = "The instance type for all consul server nodes."
  default     = "t2.micro"
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of cidr block from which inbound ssh traffic should be allowed."
  type        = "list"
}
