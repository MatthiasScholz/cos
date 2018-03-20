variable "ip_prefix" {
  description = "ip prefix for this environment"
  default     = "10.128"
}

variable "stack_name" {
  description = "shortcut for this stack"
  default     = "NOMAD"
}

variable "az_postfixes" {
  description = "list of AZ postfixes"
  type        = "list"
  default     = ["a","b"]
}

variable "region" {
  description = "region this stack should be applied to"
}

variable "deploy_profile" {
  description = "name of profile in ~/.aws/credentials file which should be used for deploying this infra"
  default     = "home"
}
