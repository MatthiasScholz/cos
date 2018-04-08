#### [General] Required Variables #################################################################
variable "deploy_profile" {
  description = "Name of profile in ~/.aws/credentials file which should be used for deploying this infra."
}

#### [General] Optional Variables ##################################################################
variable "nomad_server_scaling_cfg" {
  description = "Scaling configuration for the nomad servers."
  type        = "map"

  default = {
    "min"              = 3
    "max"              = 3
    "desired_capacity" = 3
  }
}

variable "nomad_num_clients" {
  description = "The number of Nomad client nodes to deploy. You can deploy as many as you need to run your jobs."
  default     = 3
}
