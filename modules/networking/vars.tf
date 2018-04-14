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
  default     = ["52.46.128.0/19", "52.46.164.0/23", "52.46.168.0/23", "52.46.170.0/23", "52.92.16.0/20", "52.93.1.0/24", "52.93.3.0/24", "52.93.4.0/24", "52.93.51.28/32", "52.93.51.29/32", "52.93.249.0/24", "52.94.0.0/22", "52.94.68.0/24", "52.94.124.0/22", "52.94.192.0/22", "52.94.224.0/20", "52.94.240.0/22", "52.94.244.0/22", "52.94.252.0/23", "52.94.254.0/23", "52.95.48.0/22", "52.95.62.0/24", "52.95.63.0/24", "52.95.108.0/23", "52.119.196.0/22", "52.119.206.0/23", "52.119.212.0/23", "52.119.214.0/23", "52.119.224.0/21", "52.119.232.0/21", "52.144.192.0/26", "52.144.192.64/26", "52.144.192.128/26", "52.144.192.192/26", "52.144.193.0/26", "52.144.193.64/26", "52.144.193.128/26", "52.144.194.0/26", "52.144.195.0/26", "52.216.0.0/15", "54.231.0.0/17", "54.231.244.0/22", "54.239.0.0/28", "54.239.8.0/21", "54.239.16.0/20", "54.239.98.0/24", "54.239.104.0/23", "54.239.108.0/22", "54.240.196.0/24", "54.240.202.0/24", "54.240.208.0/22", "54.240.216.0/22", "54.240.228.0/23", "54.240.232.0/22", "72.21.192.0/19", "172.96.97.0/24", "176.32.96.0/21", "176.32.120.0/22", "205.251.224.0/22", "205.251.240.0/22", "205.251.244.0/23", "205.251.246.0/24", "205.251.247.0/24", "205.251.248.0/24", "207.171.160.0/20", "207.171.176.0/20"]
}
