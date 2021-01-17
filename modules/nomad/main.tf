locals {
  short_dc_name     = format("%.10s", var.datacenter_name)
  base_cluster_name = "${var.stack_name}-NMS-${local.short_dc_name}"
}