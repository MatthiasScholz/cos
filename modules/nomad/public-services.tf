# reading values from the client_public_services_cfg
locals {
  publ_srv_data_center      = "${lookup(var.client_public_services_cfg,"data-center","INVALID")}"
  publ_srv_min              = "${lookup(var.client_public_services_cfg,"min","INVALID")}"
  publ_srv_max              = "${lookup(var.client_public_services_cfg,"max","INVALID")}"
  publ_srv_desired_capacity = "${lookup(var.client_public_services_cfg,"desired_capacity","INVALID")}"
  publ_srv_instance_type    = "${lookup(var.client_public_services_cfg,"instance_type","INVALID")}"
  publ_cluster_name         = "nomad-client-${local.publ_srv_data_center}"
}

module "clients_public_services" {
  source = "git::https://github.com/hashicorp/terraform-aws-nomad.git//modules/nomad-cluster?ref=v0.3.0"

  cluster_name            = "${local.publ_cluster_name}"
  cluster_tag_value       = "${local.publ_cluster_name}"
  instance_type           = "${local.publ_srv_instance_type}"
  ami_id                  = "${var.ami_id_clients}"
  vpc_id                  = "${var.vpc_id}"
  subnet_ids              = "${var.clients_public_services_subnet_ids}"
  allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
  user_data               = "${data.template_file.user_data_clients_public_services.rendered}"

  # To keep the example simple, we are using a fixed-size cluster. In real-world usage, you could use auto scaling
  # policies to dynamically resize the cluster in response to load.
  min_size = "${local.publ_srv_min}"

  max_size         = "${local.publ_srv_max}"
  desired_capacity = "${local.publ_srv_desired_capacity}"

  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"

  # HACK: Take the connected ALB configuration for the nomad client ui export.
  # FIXME: This will open port: 80 as well, but this is negligible.
  #    "${aws_security_group.sg_alb.id}",
  security_groups = [
    "${aws_security_group.sg_client.id}",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our client Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------
module "consul_iam_policies_public_services" {
  source = "git::https://github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.3.1"

  iam_role_id = "${module.clients_public_services.iam_role_id}"
}

# This script will configure and start Consul and Nomad
data "template_file" "user_data_clients_public_services" {
  template = "${file("${path.module}/user-data-nomad-client.sh")}"

  vars {
    cluster_tag_key   = "${var.consul_cluster_tag_key}"
    cluster_tag_value = "${var.consul_cluster_tag_value}"
    datacenter        = "${local.publ_srv_data_center}"
  }
}
