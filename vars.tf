#### [General] Required Variables #################################################################
variable "aws_region" {
  description = "region this stack should be applied to"
}

variable "alb_public_services_arn" {
  description = "The arn of the alb for public-services access."
}

variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "alb_subnet_ids" {
  description = "Ids of the subnets to deploy the alb's into."
  type        = "list"
}

#### [Nomad] Required Variables ###################################################################
variable "nomad_ami_id_servers" {
  description = "The ID of the AMI to be used for the nomad server nodes."
}

variable "nomad_ami_id_clients" {
  description = "The ID of the AMI to be used for the nomad clientnodes."
}

variable "nomad_clients_public_services_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad client nodes providing the data-center public-services into."
  type        = "list"
}

variable "nomad_clients_private_services_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad client nodes providing the data-center private-services into."
  type        = "list"
}

variable "nomad_clients_content_connector_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad client nodes providing the data-center content-connector into."
  type        = "list"
}

variable "nomad_clients_backoffice_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad client nodes providing the data-center backoffice into."
  type        = "list"
}

variable "nomad_server_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad servers into."
  type        = "list"
}

#### [Consul] Required Variables ##################################################################
variable "consul_ami_id" {
  description = "The ID of the AMI to be used for the consul nodes."
}

variable "consul_server_subnet_ids" {
  description = "Ids of the subnets to deploy the consul servers into."
  type        = "list"
}

#### [General] Optional Variables ##################################################################
variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "env_name" {
  description = "Name of the environment (i.e. prod)."
  default     = "playground"
}

variable "unique_postfix" {
  description = "A postfix to be used to generate unique resource names per deployment."
  default     = ""
}

variable "instance_type_server" {
  description = "The instance type for all nomad and consul server nodes."
  default     = "t2.micro"
}

variable "instance_type_client" {
  description = "The instance type for all nomad client nodes."
  default     = "t2.micro"
}

variable "stack_name" {
  description = "Shortcut for this stack."
  default     = "COS"
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of cidr block from which inbound ssh traffic should be allowed."
  type        = "list"
  default     = []
}

#### [Nomad] Optional Variables ###################################################################
variable "nomad_cluster_name" {
  description = "What to name the Nomad cluster and all of its associated resources."
  default     = "nomad-example"
}

variable "nomad_num_clients" {
  description = "The number of Nomad client nodes to deploy. You can deploy as many as you need to run your jobs."
  default     = 3
}

variable "nomad_server_scaling_cfg" {
  description = "Scaling configuration for the nomad servers."
  type        = "map"

  default = {
    "min"              = 3
    "max"              = 3
    "desired_capacity" = 3
  }
}

#### [Consul] Optional Variables ##################################################################

variable "consul_cluster_name" {
  description = "What to name the Consul cluster and all of its associated resources."
  default     = "consul-example"
}

variable "consul_num_servers" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "consul_instance_type" {
  description = "The instance type for all consul server nodes."
  default     = "t2.micro"
}
