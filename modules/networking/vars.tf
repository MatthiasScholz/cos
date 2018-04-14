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
  description = "List of ip-ranges for accessing aws services (S3, EC2, ElastiCache, ..) in us-east-1 see: http://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html"
  type        = "list"
  default     = ["52.46.0.0/16", "52.92.0.0/16", "52.93.0.0/16", "52.94.0.0/16", "52.95.0.0/16", "52.119.0.0/16", "52.144.0.0/16", "52.216.0.0/15", "54.231.0.0/16", "54.239.0.0/16", "54.240.0.0/16", "72.21.0.0/16", "172.96.0.0/16", "176.32.0.0/16", "205.251.0.0/16", "207.171.0.0/16"]
}
