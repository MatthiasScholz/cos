variable "deploy_profile" {
  description = "name of profile in ~/.aws/credentials file which should be used for deploying this infra"
}

variable "aws_region" {
  description = "region this stack should be applied to"
  default     = "us-east-1"
}

variable "env_name" {
  description = "name of the environment (i.e. prod)"
  default     = "playground"
}

variable "nomad_cluster_name" {
  description = "What to name the Nomad cluster and all of its associated resources."
  default     = "nomad-example"
}

variable "consul_cluster_name" {
  description = "What to name the Consul cluster and all of its associated resources."
  default     = "consul-example"
}

variable "ami" {
  description = "AMI for all the nomad instances."
  default     = "ami-a23feadf"
}
