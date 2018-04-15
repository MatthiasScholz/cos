# Terraform 0.9.5 suffered from https://github.com/hashicorp/terraform/issues/14399, which causes this template the
# conditionals in this template to fail.
terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

locals {
  short_dc_name     = "${format("%.10s",var.datacenter_name)}"
  cluster_prefix    = "${var.stack_name}-NMC"
  base_cluster_name = "${local.cluster_prefix}-${local.short_dc_name}"
}
