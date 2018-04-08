# Terraform 0.9.5 suffered from https://github.com/hashicorp/terraform/issues/14399, which causes this template the
# conditionals in this template to fail.
terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

locals {
  short_dc_name     = "${format("%.1s",var.datacenter_name)}"
  base_cluster_name = "${var.stack_name}-NMS-${local.short_dc_name}"
}
