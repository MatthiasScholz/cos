# NOTE: Taken from:
# https://github.com/hashicorp/terraform-aws-consul/blob/bc8f83760cab2a29dbfceaebe30390c1dbeb3e48/modules/consul-iam-policies/variables.tf
# -------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# -------------------------------------------------------------------------------------------------------------------

variable "iam_role_id" {
  description = "The ID of the IAM Role to which these IAM policies should be attached"
  type        = string
}

variable "cluster_tag_value" {
  description = "This variable defines the value of the tag defined by consul_cluster_tag_key. All consul-server instances will be tagged with 'consul_cluster_tag_value:consul_cluster_tag_value'."
  default     = "consul-example-server"
}
