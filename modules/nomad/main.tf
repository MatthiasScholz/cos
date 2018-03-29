# Terraform 0.9.5 suffered from https://github.com/hashicorp/terraform/issues/14399, which causes this template the
# conditionals in this template to fail.
terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

locals {
  client_cluster_name = "${var.cluster_name}-client"
  server_cluster_name = "${var.cluster_name}-server"
}
