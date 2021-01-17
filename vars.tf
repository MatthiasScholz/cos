#### [General] Required Variables #################################################################
variable "aws_region" {
  description = "region this stack should be applied to"
}

variable "alb_ingress_https_listener_arn" {
  description = "The arn of the https alb listener for ingress data."
}

variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "alb_subnet_ids" {
  description = "Ids of the subnets to deploy the alb's into."
  type        = list(string)
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
  type        = list(string)
}

variable "nomad_clients_private_services_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad client nodes providing the data-center private-services into."
  type        = list(string)
}

variable "nomad_clients_content_connector_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad client nodes providing the data-center content-connector into."
  type        = list(string)
}

variable "nomad_clients_backoffice_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad client nodes providing the data-center backoffice into."
  type        = list(string)
}

variable "nomad_server_subnet_ids" {
  description = "Ids of the subnets to deploy the nomad servers into."
  type        = list(string)
}

#### [Consul] Required Variables ##################################################################
variable "consul_ami_id" {
  description = "The ID of the AMI to be used for the consul nodes."
}

variable "consul_server_subnet_ids" {
  description = "Ids of the subnets to deploy the consul servers into."
  type        = list(string)
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

variable "stack_name" {
  description = "Shortcut for this stack."
  default     = "COS"
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of cidr block from which inbound ssh traffic should be allowed."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks_for_ui_alb" {
  description = "Map for cidr blocks that should get access over alb. The format is name:cidr-block. I.e. 'my_cidr'='90.250.75.79/32'"
  type        = map(string)

  default = {
    "all" = "0.0.0.0/0"
  }
}

variable "ui_alb_https_listener_cert_arn" {
  description = "ARN of the certificate that should be used to set up the https endpoint for the ui-alb's. If not provided, a http enpoint will be created."
  default     = ""
}

variable "ui_alb_use_https_listener" {
  description = "If true, the https endpoint for the ui-albs will be created instead of the http one. Precondition for this is that ui_alb_https_listener_cert_arn is set apropriately."
  default     = false
}

variable "alb_backoffice_https_listener_arn" {
  description = "The arn of the https alb listener for the backoffice data-center. To attach the alb listener to the backoffice data-center the variable attach_backoffice_alb_listener has to be set to true as well."
  default     = ""
}

variable "attach_backoffice_alb_listener" {
  description = "Set this to true in case an alb shall be attached to the backoffice data-center. In this case the variable alb_backoffice_https_listener_arn has to be set specifying the correct alb listener."
  default     = false
}

#### [Nomad] Optional Variables ###################################################################
variable "nomad_server_scaling_cfg" {
  description = "Scaling configuration for the nomad servers."
  type        = map(string)

  default = {
    "min"              = 3
    "max"              = 3
    "desired_capacity" = 3
  }
}

variable "nomad_private_services_dc_node_cfg" {
  description = "Node configuration for the nomad nodes of the private-services data center."
  type        = map(string)

  default = {
    "min"              = 1
    "max"              = 1
    "desired_capacity" = 1
    "instance_type"    = "t2.micro"
  }
}

# Example for a ebs_block_device created from a snapshot and one with a certain size.
# ebs_block_devices = [{
#    "device_name" = "/dev/xvdf"
#    "snapshot_id" = "snap-XYZ"
#  },
#  {
#    "device_name" = "/dev/xvde"
#    "volume_size" = "50"
#  }]
variable "ebs_block_devices_private_services_dc" {
  description = "List of ebs volume definitions for those ebs_volumes that should be added to the instances created with the EC2 launch-configurationd. Each element in the list is a map containing keys defined for ebs_block_device (see: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#ebs_block_device."
  type        = any

  default = []
}

# Space list of device to mount target entries for the private_services dc
# A device to mount target entry is a key value pair (separated by ' ').
# key ... is the name of the device (i.e. /dev/xvdf)
# value ... is the name of the mount target (i.e. /mnt/map1)
# Example: ["/dev/xvde:/mnt/map1","/dev/xvdf:/mnt/map2"]
variable "device_to_mount_target_map_private_services_dc" {
  description = "List of device to mount target entries."
  type        = list(string)
  default     = []
}

# List of tags to add to the private_services datacenter instances
# A tag is a map consiting of key (string), value (string) and propagate (bool) at launch
# key ... the key for the tag (i.e. version)
# value ... the value (i.e. v1.2.9)
# Example:
#  additional_instance_tags_private_services_dc = [ {
#      "key"                 = "version"
#      "value"               = "v1.2.9"
#      "propagate_at_launch" = "true"
#    }]
variable "additional_instance_tags_private_services_dc" {
  description = "List of tags to add to the private_services datacenter instances. The entries of the list are maps consiting of key, value and propagate at launch."
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
  default = []
}

variable "nomad_public_services_dc_node_cfg" {
  description = "Node configuration for the nomad nodes of the public-services data center."
  type        = map(string)

  default = {
    "min"              = 1
    "max"              = 1
    "desired_capacity" = 1
    "instance_type"    = "t2.micro"
  }
}

# Example for a ebs_block_device created from a snapshot and one with a certain size.
# ebs_block_devices = [{
#    "device_name" = "/dev/xvdf"
#    "snapshot_id" = "snap-XYZ"
#  },
#  {
#    "device_name" = "/dev/xvde"
#    "volume_size" = "50"
#  }]
variable "ebs_block_devices_public_services_dc" {
  description = "List of ebs volume definitions for those ebs_volumes that should be added to the instances of the public-services dc. Each element in the list is a map containing keys defined for ebs_block_device (see: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#ebs_block_device."
  type        = any

  default = []
}

# Space list of device to mount target entries for the public_services dc
# A device to mount target entry is a key value pair (separated by ' ').
# key ... is the name of the device (i.e. /dev/xvdf)
# value ... is the name of the mount target (i.e. /mnt/map1)
# Example: ["/dev/xvde:/mnt/map1","/dev/xvdf:/mnt/map2"]
variable "device_to_mount_target_map_public_services_dc" {
  description = "List of device to mount target entries."
  type        = list(string)
  default     = []
}

# List of tags to add to the public_services datacenter instances
# A tag is a map consiting of key (string), value (string) and propagate (bool) at launch
# key ... the key for the tag (i.e. version)
# value ... the value (i.e. v1.2.9)
# Example:
#  additional_instance_tags_public_services_dc = [ {
#      "key"                 = "version"
#      "value"               = "v1.2.9"
#      "propagate_at_launch" = "true"
#    }]
variable "additional_instance_tags_public_services_dc" {
  description = "List of tags to add to the public_services datacenter instances. The entries of the list are maps consiting of key, value and propagate at launch."
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
  default = []
}

variable "nomad_backoffice_dc_node_cfg" {
  description = "Node configuration for the nomad nodes of the backoffice data center."
  type        = map(string)

  default = {
    "min"              = 1
    "max"              = 1
    "desired_capacity" = 1
    "instance_type"    = "t2.micro"
  }
}

# Example for a ebs_block_device created from a snapshot and one with a certain size.
# ebs_block_devices = [{
#    "device_name" = "/dev/xvdf"
#    "snapshot_id" = "snap-XYZ"
#  },
#  {
#    "device_name" = "/dev/xvde"
#    "volume_size" = "50"
#  }]
variable "ebs_block_devices_backoffice_dc" {
  description = "List of ebs volume definitions for those ebs_volumes that should be added to the instances of the backoffice dc. Each element in the list is a map containing keys defined for ebs_block_device (see: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#ebs_block_device."
  type        = any

  default = []
}

# Space list of device to mount target entries for the backoffice dc
# A device to mount target entry is a key value pair (separated by ' ').
# key ... is the name of the device (i.e. /dev/xvdf)
# value ... is the name of the mount target (i.e. /mnt/map1)
# Example: ["/dev/xvde:/mnt/map1","/dev/xvdf:/mnt/map2"]
variable "device_to_mount_target_map_backoffice_dc" {
  description = "List of device to mount target entries."
  type        = list(string)
  default     = []
}

# List of tags to add to the backoffice datacenter instances
# A tag is a map consiting of key (string), value (string) and propagate (bool) at launch
# key ... the key for the tag (i.e. version)
# value ... the value (i.e. v1.2.9)
# Example:
#  additional_instance_tags_backoffice_dc = [ {
#      "key"                 = "version"
#      "value"               = "v1.2.9"
#      "propagate_at_launch" = "true"
#    }]
variable "additional_instance_tags_backoffice_dc" {
  description = "List of tags to add to the backoffice datacenter instances. The entries of the list are maps consiting of key, value and propagate at launch."
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
  default = []
}

variable "nomad_content_connector_dc_node_cfg" {
  description = "Node configuration for the nomad nodes of the content-connetor data center."
  type        = map(string)

  default = {
    "min"              = 1
    "max"              = 1
    "desired_capacity" = 1
    "instance_type"    = "t2.micro"
  }
}

# Example for a ebs_block_device created from a snapshot and one with a certain size.
# ebs_block_devices = [{
#    "device_name" = "/dev/xvdf"
#    "snapshot_id" = "snap-XYZ"
#  },
#  {
#    "device_name" = "/dev/xvde"
#    "volume_size" = "50"
#  }]
variable "ebs_block_devices_content_connector_dc" {
  description = "List of ebs volume definitions for those ebs_volumes that should be added to the instances of the content-connector dc. Each element in the list is a map containing keys defined for ebs_block_device (see: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#ebs_block_device."
  type        = any

  default = []
}

# Space list of device to mount target entries for the content-connector dc
# A device to mount target entry is a key value pair (separated by ' ').
# key ... is the name of the device (i.e. /dev/xvdf)
# value ... is the name of the mount target (i.e. /mnt/map1)
# Example: ["/dev/xvde:/mnt/map1","/dev/xvdf:/mnt/map2"]
variable "device_to_mount_target_map_content_connector_dc" {
  description = "List of device to mount target entries."
  type        = list(string)
  default     = []
}

# List of tags to add to the content_connector datacenter instances
# A tag is a map consiting of key (string), value (string) and propagate (bool) at launch
# key ... the key for the tag (i.e. version)
# value ... the value (i.e. v1.2.9)
# Example:
#  additional_instance_tags_content_connector_dc = [ {
#      "key"                 = "version"
#      "value"               = "v1.2.9"
#      "propagate_at_launch" = "true"
#    }]
variable "additional_instance_tags_content_connector_dc" {
  description = "List of tags to add to the content_connector datacenter instances. The entries of the list are maps consiting of key, value and propagate at launch."
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
  default = []
}

variable "efs_dns_name" {
  description = "DNS name of the efs this nodes should have access to."
  default     = ""
}

variable "map_bucket_name" {
  description = "name of the s3 bucket carrying the maps."
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
  type        = list(string)
  default     = []
}

