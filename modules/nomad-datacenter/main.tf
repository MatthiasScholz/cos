locals {
  short_dc_name     = format("%.10s", var.datacenter_name)
  cluster_prefix    = "${var.stack_name}-NMC"
  base_cluster_name = "${local.cluster_prefix}-${local.short_dc_name}"
}

