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
