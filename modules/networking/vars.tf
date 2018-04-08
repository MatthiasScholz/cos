variable "ip_prefix" {
  description = "ip prefix for this environment"
  default     = "10.128"
}

variable "stack_name" {
  description = "shortcut for this stack"
  default     = "COS"
}

variable "az_postfixes" {
  description = "list of AZ postfixes"
  type        = "list"
  default     = ["a", "b", "c"]
}

variable "region" {
  description = "region this stack should be applied to"
}

variable "env_name" {
  description = "name of the environment (i.e. prod)"
  default     = "playground"
}

variable "unique_postfix" {
  description = "A postfix that will be used in names to avoid collisions (mainly used for name tags)."
  default     = ""
}

variable "aws_ip_address_ranges" {
  description = "list of ip-ranges for accessing aws services (S3, EC2, ElastiCache, ..) see: http://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html"
  type        = "list"

  # these ip-rages are valid for eu-central and were taken from http://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html
  default = ["18.194.0.0/15", "18.196.0.0/15", "52.28.0.0/16", "52.29.0.0/16", "52.57.0.0/16", "52.58.0.0/15", "52.92.68.0/22", "52.94.17.0/24", "52.94.198.48/28", "52.94.204.0/23", "52.94.248.112/28", "52.95.248.0/24", "52.95.255.128/28", "52.219.44.0/22", "52.219.72.0/22", "54.93.0.0/16", "54.231.192.0/20", "54.239.0.160/28", "54.239.4.0/22", "54.239.54.0/23", "54.239.56.0/21", "35.156.0.0/14"]
}
