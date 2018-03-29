# reading values from the client_content_connector_cfg
locals {
  content_conn_data_center      = "${lookup(var.client_content_connector_cfg,"data-center","INVALID")}"
  content_conn_min              = "${lookup(var.client_content_connector_cfg,"min","INVALID")}"
  content_conn_max              = "${lookup(var.client_content_connector_cfg,"max","INVALID")}"
  content_conn_desired_capacity = "${lookup(var.client_content_connector_cfg,"desired_capacity","INVALID")}"
  content_conn_instance_type    = "${lookup(var.client_content_connector_cfg,"instance_type","INVALID")}"
  content_conn_cluster_name     = "${var.stack_name}-${var.env_name}-${local.content_conn_data_center}"
}

module "clients_content_connector" {
  source = "git::https://github.com/hashicorp/terraform-aws-nomad.git//modules/nomad-cluster?ref=v0.3.0"

  cluster_name            = "${local.content_conn_cluster_name}"
  cluster_tag_value       = "${local.content_conn_cluster_name}"
  instance_type           = "${local.content_conn_instance_type}"
  ami_id                  = "${var.ami_id_clients}"
  vpc_id                  = "${var.vpc_id}"
  subnet_ids              = "${var.clients_content_connector_subnet_ids}"
  allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
  user_data               = "${data.template_file.user_data_clients_content_connector.rendered}"
  ssh_key_name            = "${var.ssh_key_name}"

  # To keep the example simple, we are using a fixed-size cluster. In real-world usage, you could use auto scaling
  # policies to dynamically resize the cluster in response to load.

  min_size         = "${local.content_conn_min}"
  max_size         = "${local.content_conn_max}"
  desired_capacity = "${local.content_conn_desired_capacity}"
  security_groups = [
    "${aws_security_group.sg_client.id}",
    "${aws_security_group.sg_content_connector.id}",
  ]
  # Access over cidr blocks is disabled here.
  # The need access for the nomad-server is granted over the 
  # aws_security_group.sg_client.id.
  allowed_inbound_cidr_blocks = ["0.0.0.0/32"]
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our client Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------
module "consul_iam_policies_content_connector" {
  source = "git::https://github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.3.1"

  iam_role_id = "${module.clients_content_connector.iam_role_id}"
}

# This script will configure and start Consul and Nomad
data "template_file" "user_data_clients_content_connector" {
  template = "${file("${path.module}/user-data-nomad-client.sh")}"

  vars {
    cluster_tag_key   = "${var.consul_cluster_tag_key}"
    cluster_tag_value = "${var.consul_cluster_tag_value}"
    datacenter        = "${local.content_conn_data_center}"
  }
}
