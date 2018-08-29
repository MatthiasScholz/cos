#### [General] Required Variables #################################################################
variable "aws_region" {
  description = "region this stack should be applied to"
}

variable "alb_ingress_http_listener_arn" {
  description = "The arn of the http alb listener for ingress data."
}

variable "alb_ingress_https_listener_arn" {
  description = "The arn of the https alb listener for ingress data."
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

variable "allowed_cidr_blocks_for_ui_alb" {
  description = "Map for cidr blocks that should get access over alb. The format is name:cidr-block. I.e. 'my_cidr'='90.250.75.79/32'"
  type        = "map"

  default = {
    "all" = "0.0.0.0/0"
  }
}

#### [Nomad] Optional Variables ###################################################################
variable "nomad_server_scaling_cfg" {
  description = "Scaling configuration for the nomad servers."
  type        = "map"

  default = {
    "min"              = 3
    "max"              = 3
    "desired_capacity" = 3
  }
}

variable "nomad_client_scaling_cfg" {
  description = "Scaling configuration for the nomad nodes to deploy for this datacenter. You can deploy as many as you need to run your jobs."
  type        = "map"

  default = {
    "min"              = 1
    "max"              = 1
    "desired_capacity" = 1
  }
}

variable "efs_dns_name" {
  description = "DNS name of the efs this nodes should have access to."
  default     = ""
}

#### [Consul] Optional Variables ##################################################################
variable "consul_num_servers" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "consul_instance_type" {
  description = "The instance type for all consul server nodes."
  default     = "t2.micro"
}

variable "ecr_repositories" {
  description = "List of names for the ECR repositories to be created. Nomad will use them to get docker images from it in the job files."
  type        = "list"
  default     = []
}
