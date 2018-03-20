# Terraform 0.9.5 suffered from https://github.com/hashicorp/terraform/issues/14399, which causes this template the
# conditionals in this template to fail.
terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

locals {
  nomad_client_cluster_name = "${var.nomad_cluster_name}-client"
  nomad_server_cluster_name = "${var.nomad_cluster_name}-server"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD SERVER NODES
# ---------------------------------------------------------------------------------------------------------------------
module "nomad_servers" {
  source = "git::https://github.com/hashicorp/terraform-aws-nomad.git//modules/nomad-cluster?ref=v0.3.0"

  cluster_name      = "${local.nomad_server_cluster_name}"
  cluster_tag_value = "${local.nomad_server_cluster_name}"
  instance_type     = "t2.micro"

  # You should typically use a fixed size of 3 or 5 for your Nomad server cluster
  min_size         = "${var.num_nomad_servers}"
  max_size         = "${var.num_nomad_servers}"
  desired_capacity = "${var.num_nomad_servers}"

  ami_id    = "${var.nomad_ami_id}"
  user_data = "${data.template_file.user_data_nomad_server.rendered}"

  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.nomad_server_subnet_ids}"

  # To make testing easier, we allow requests from any IP address here but in a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
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

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH NOMAD SERVER NODE WHEN IT'S BOOTING
# This script will configure and start Nomad
# ---------------------------------------------------------------------------------------------------------------------
data "template_file" "user_data_nomad_server" {
  template = "${file("${path.module}/user-data-nomad-server.sh")}"

  vars {
    num_servers       = "${var.num_nomad_servers}"
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.consul_cluster_name}"
    datacenter        = "backoffice"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONSUL SERVER NODES
# ---------------------------------------------------------------------------------------------------------------------
module "consul_servers" {
  source = "git::https://github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.3.1"

  cluster_name  = "${var.consul_cluster_name}-server"
  cluster_size  = "${var.num_consul_servers}"
  instance_type = "t2.micro"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "${var.cluster_tag_key}"
  cluster_tag_value = "${var.consul_cluster_name}"

  ami_id    = "${var.consul_ami_id}"
  user_data = "${data.template_file.user_data_consul_server.rendered}"

  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.nomad_server_subnet_ids}"

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CONSUL SERVER EC2 INSTANCE WHEN IT'S BOOTING
# This script will configure and start Consul
# ---------------------------------------------------------------------------------------------------------------------
data "template_file" "user_data_consul_server" {
  template = "${file("${path.module}/user-data-consul-server.sh")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.consul_cluster_name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD CLIENT NODES
# ---------------------------------------------------------------------------------------------------------------------
module "nomad_clients" {
  source = "git::https://github.com/hashicorp/terraform-aws-nomad.git//modules/nomad-cluster?ref=v0.3.0"

  cluster_name      = "${local.nomad_client_cluster_name}"
  cluster_tag_value = "${local.nomad_client_cluster_name}"
  instance_type     = "t2.micro"

  # To keep the example simple, we are using a fixed-size cluster. In real-world usage, you could use auto scaling
  # policies to dynamically resize the cluster in response to load.
  min_size = "${var.num_nomad_clients}"

  max_size         = "${var.num_nomad_clients}"
  desired_capacity = "${var.num_nomad_clients}"
  ami_id           = "${var.nomad_ami_id}"
  user_data        = "${data.template_file.user_data_nomad_client.rendered}"
  vpc_id           = "${var.vpc_id}"
  subnet_ids       = "${var.nomad_server_subnet_ids}"

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our client Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_clients" {
  source = "git::https://github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.3.1"

  iam_role_id = "${module.nomad_clients.iam_role_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CLIENT NODE WHEN IT'S BOOTING
# This script will configure and start Consul and Nomad
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_nomad_client" {
  template = "${file("${path.module}/user-data-nomad-client.sh")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.consul_cluster_name}"
    datacenter        = "public-services"
  }
}
