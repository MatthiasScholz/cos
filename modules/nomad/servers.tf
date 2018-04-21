# reading values from the node_scaling_cfg
locals {
  min              = "${lookup(var.node_scaling_cfg,"min","INVALID")}"
  max              = "${lookup(var.node_scaling_cfg,"max","INVALID")}"
  desired_capacity = "${lookup(var.node_scaling_cfg,"desired_capacity","INVALID")}"
  cluster_name     = "${local.base_cluster_name}${var.unique_postfix}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD SERVER NODES
# ---------------------------------------------------------------------------------------------------------------------
module "nomad_servers" {
  source = "git::https://github.com/hashicorp/terraform-aws-nomad.git//modules/nomad-cluster?ref=v0.3.1"

  cluster_name                = "${local.cluster_name}"
  cluster_tag_value           = "${local.cluster_name}"
  instance_type               = "${var.instance_type}"
  ami_id                      = "${var.ami_id}"
  vpc_id                      = "${var.vpc_id}"
  subnet_ids                  = "${var.subnet_ids}"
  allowed_ssh_cidr_blocks     = "${var.allowed_ssh_cidr_blocks}"
  user_data                   = "${data.template_file.user_data_server.rendered}"
  ssh_key_name                = "${var.ssh_key_name}"
  associate_public_ip_address = false

  # You should typically use a fixed size of 3 or 5 for your Nomad server cluster
  min_size         = "${local.min}"
  max_size         = "${local.max}"
  desired_capacity = "${local.desired_capacity}"

  security_groups = ["${aws_security_group.sg_server.id}"]

  # Access over cidr blocks is disabled here.
  # The need access for the nomad-server is granted over the
  # aws_security_group.sg_nomad_server_access.id.
  allowed_inbound_cidr_blocks = ["0.0.0.0/32"]

  # propagate tags to the instances
  tags = [
    {
      "key"                 = "datacenter"
      "value"               = "${var.datacenter_name}"
      "propagate_at_launch" = "true"
    },
    {
      "key"                 = "node-type"
      "value"               = "server"
      "propagate_at_launch" = "true"
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our server Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------
module "consul_iam_policies_servers" {
  source      = "git::https://github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.3.1"
  iam_role_id = "${module.nomad_servers.iam_role_id}"
}

# This script will configure and start Consul and Nomad
data "template_file" "user_data_server" {
  template = "${file("${path.module}/user-data-nomad-server.sh")}"

  vars {
    num_servers       = "${local.desired_capacity}"
    cluster_tag_key   = "${var.consul_cluster_tag_key}"
    cluster_tag_value = "${var.consul_cluster_tag_value}"
    datacenter        = "${var.datacenter_name}"
  }
}
