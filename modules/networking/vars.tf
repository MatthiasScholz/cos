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

  default = ["18.0.0.0/8", "23.0.0.0/8", "34.0.0.0/8", "35.0.0.0/8", "50.0.0.0/8", "52.0.0.0/8", "54.0.0.0/8", "67.0.0.0/8", "72.0.0.0/8", "75.0.0.0/8", "107.0.0.0/8", "174.0.0.0/8", "184.0.0.0/8", "204.0.0.0/8", "216.0.0.0/8", "172.0.0.0/8", "176.0.0.0/8", "205.0.0.0/8", "207.0.0.0/8",
    "192.30.253.0/24",
  ] # "192.30.253.0/24" is for github
}
