# Terraform 0.9.5 suffered from https://github.com/hashicorp/terraform/issues/14399, which causes this template the
# conditionals in this template to fail.
terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

locals {
  short_dc_name     = "${format("%.10s",var.datacenter_name)}"
  base_cluster_name = "${var.stack_name}-NMS-${local.short_dc_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD CLIENT NODES
# ---------------------------------------------------------------------------------------------------------------------
# HACK module "nomad_clients" {
# HACK   # source = "git::https://github.com/hashicorp/terraform-aws-nomad.git//modules/nomad-cluster?ref=v0.3.0"
# HACK   # HACK: Playing around with GlusterFS - additional EBS volume per client node needed.
# HACK   source = "../../../terraform-aws-nomad/modules/nomad-cluster"
# HACK
# HACK   cluster_name      = "${local.nomad_client_cluster_name}"
# HACK   cluster_tag_value = "${local.nomad_client_cluster_name}"
# HACK   instance_type     = "${var.instance_type_client}"
# HACK
# HACK   # To keep the example simple, we are using a fixed-size cluster. In real-world usage, you could use auto scaling
# HACK   # policies to dynamically resize the cluster in response to load.
# HACK   min_size = "${var.num_nomad_clients}"
# HACK
# HACK   max_size         = "${var.num_nomad_clients}"
# HACK   desired_capacity = "${var.num_nomad_clients}"
# HACK   ami_id           = "${var.nomad_ami_id_clients}"
# HACK   user_data        = "${data.template_file.user_data_nomad_client.rendered}"
# HACK   vpc_id           = "${var.vpc_id}"
# HACK   subnet_ids       = "${var.nomad_server_subnet_ids}"
# HACK
# HACK   # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
# HACK   # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
# HACK   allowed_ssh_cidr_blocks = ["0.0.0.0/0"]
# HACK
# HACK   allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
# HACK   ssh_key_name                = "${var.ssh_key_name}"
# HACK
# HACK   # HACK: Take the connected ALB configuration for the nomad client ui export.
# HACK   # FIXME: This will open port: 80 as well, but this is negligible.
# HACK   #    "${aws_security_group.sg_alb.id}",
# HACK   security_groups = [
# HACK     "${aws_security_group.sg_client.id}",
# HACK     "${aws_security_group.sg_client_glusterfs.id}",
# HACK   ]
# HACK }
