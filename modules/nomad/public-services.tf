module "clients_public_services" {
  source = "git::https://github.com/hashicorp/terraform-aws-nomad.git//modules/nomad-cluster?ref=v0.3.0"

  cluster_name      = "${local.client_cluster_name}"
  cluster_tag_value = "${local.client_cluster_name}"
  instance_type     = "${var.instance_type_client}"

  # To keep the example simple, we are using a fixed-size cluster. In real-world usage, you could use auto scaling
  # policies to dynamically resize the cluster in response to load.
  min_size = "${var.num_clients}"

  max_size         = "${var.num_clients}"
  desired_capacity = "${var.num_clients}"
  ami_id           = "${var.ami_id_clients}"
  user_data        = "${data.template_file.user_data_clients_public_services.rendered}"
  vpc_id           = "${var.vpc_id}"
  subnet_ids       = "${var.server_subnet_ids}"

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

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
    datacenter        = "public-services"
  }
}
