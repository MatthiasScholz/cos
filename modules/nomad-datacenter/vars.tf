#### Required Variables ############################################
variable "ami_id" {
  description = "The ID of the AMI to be used for the nomad nodes."
}

variable "vpc_id" {
  description = "Id of the vpc where to place in the instances."
}

variable "server_sg_id" {
  description = "The id of the nomad-server security group. This is needed to grant access to the datacenter nodes."
}

variable "consul_cluster_tag_key" {
  description = "This variable defines the name of the tag that is used to find the consul-servers. On each nomad instance the consul-agent searches for EC2 instances tagged with this tag and having the value of consul_cluster_tag_value."
}

variable "consul_cluster_tag_value" {
  description = "This variable defines the value of the tag defined by consul_cluster_tag_key. This is used to find the consul servers (see: consul_cluster_tag_key)."
}

variable "subnet_ids" {
  description = "Subnet id's for nomad client nodes providing this data-center."
  type        = list(string)
}

#### Optional Variables ############################################
variable "attach_ingress_alb_listener" {
  description = "If true, the datacenter nodes will be attached to the ingress http and https alb listener. Therfore the variable alb_ingress_https_listener_arn has to be set."
  default     = false
}

variable "alb_ingress_https_listener_arn" {
  description = "The arn of the alb https listener for ingress data. If not specified, no alb-attachment will be created to grant ingress access to the data-center nodes."
  default     = ""
}

variable "ingress_controller_port" {
  description = "The port of the ingress controller (i.e. fabio)."
  default     = 9999
}

variable "env_name" {
  description = "name of the environment (i.e. prod)"
  default     = "playground"
}

variable "stack_name" {
  description = "shortcut for this stack"
  default     = "COS"
}

variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "eu-central-1"
}

variable "datacenter_name" {
  description = "The name of the datacenter (i.e. backoffice)."
  default     = "dc-example"
}

variable "node_scaling_cfg" {
  description = "Scaling configuration for the nomad nodes to deploy for this datacenter. You can deploy as many as you need to run your jobs."
  type        = map(string)

  default = {
    "min"              = 1
    "max"              = 1
    "desired_capacity" = 1
  }
}

variable "instance_type" {
  description = "The instance type for nomad nodes."
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of cidr block from which inbound ssh traffic should be allowed for this datacenter."
  type        = list(string)
  default     = []
}

variable "unique_postfix" {
  description = "A postfix that will be used in names to avoid collisions (mainly used for name tags)."
  default     = ""
}

variable "efs_dns_name" {
  description = "DNS name of the efs this nodes should have access to."
  default     = ""
}

variable "map_bucket_name" {
  description = "name of the s3 bucket carrying the maps."
  default     = ""
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
variable "ebs_block_devices" {
  description = "List of ebs volume definitions for those ebs_volumes that should be added to the instances created with the EC2 launch-configurationd. Each element in the list is a map containing keys defined for ebs_block_device (see: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#ebs_block_device."
  type        = any
  default = []
}

# List of device to mount target entries.
# A device to mount target entry is a key value pair (separated by ' ').
# key ... is the name of the device (i.e. /dev/xvdf)
# value ... is the name of the mount target (i.e. /mnt/map1)
# Example: ["/dev/xvde:/mnt/map1","/dev/xvdf:/mnt/map2"]
variable "device_to_mount_target_map" {
  description = "List of device to mount target entries."
  type        = list(string)
  default     = []
}

variable "fs_type" {
  description = "The file system type to be created for devices which have no file-system yet."
  default     = "xfs"
}

# List of tags to add to the datacenter instances
# A tag is a map consiting of key (string), value (string) and propagate (bool) at launch
# key ... the key for the tag (i.e. version)
# value ... the value (i.e. v1.2.9)
# Example:
#  additional_instance_tags = [
#    {
#      "key"                 = "version"
#      "value"               = "v1.2.9"
#      "propagate_at_launch" = "true"
#    },
#    {
#      "key"                 = "map-version"
#      "value"               = "20.0092"
#      "propagate_at_launch" = "true"
#    }]
variable "additional_instance_tags" {
  description = "List of tags to add to the datacenter instances. The entries of the list are maps consiting of key, value and propagate at launch."
  type        = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
  default     = []
}

