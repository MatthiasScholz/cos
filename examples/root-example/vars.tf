#### [General] Required Variables #################################################################
variable "deploy_profile" {
  description = "Name of profile in ~/.aws/credentials file which should be used for deploying this infra."
}

variable "nomad_ami_id_servers" {
  description = "AMI ID for nomad server"
  default     = "ami-02d24827dece83bef"
}

variable "nomad_ami_id_clients" {
  description = "AMI ID for nomad nodes"
  default     = "ami-02d24827dece83bef"
}

variable "env_name" {
  description = "AWS Profile name"
  default     = "playground"
}

variable "aws_region" {
  description = "AWS Region to deploy the cluster to."
  default     = "us-east-1"
}

variable "ssh_key_name" {
  description = "AWS instance key to use for SSH login"
  default     = "kp-us-east-1-playground-instancekey"
}

variable "stack_name" {
  description = "Name of the cluster, used as prefix to identify the AWS resources belonging to the cluster."
  default     = "COS"
}

variable "server_scaling_cfg" {
  description = "Number of nomad server"
  type        = "map"

  default = {
    "min"              = 3
    "max"              = 3
    "desired_capacity" = 3
  }
}

variable "nomad_dc_node_cfg" {
  description = "Configuration for the private data-center nodes"
  type        = "map"

  default = {
    "min"              = 1
    "max"              = 1
    "desired_capacity" = 1
    "instance_type"    = "t2.micro"
  }
}

variable "ebs_block_devices_sample" {
  type = "list"

  default = [{
    "device_name" = "/dev/xvde"
    "volume_size" = "50"
  },
    {
      "device_name" = "/dev/xvdf"
      "volume_size" = "80"
    },
  ]
}

variable "device_to_mount_target_map_sample" {
  type = "list"

  default = ["/dev/xvde:/mnt/map1", "/dev/xvdf:/mnt/map2"]
}

variable "additional_instance_tags_sample" {
  type = "list"

  default = [
    {
      "key"                 = "nomad-version"
      "value"               = "vX.Y.Z"
      "propagate_at_launch" = "true"
    },
  ]
}
