locals {
  postfix             = "${length(var.unique_postfix) >= 1 ? "-${var.unique_postfix}" : ""}"
  consul_cluster_name = "${var.stack_name}-consul${local.postfix}"
}

module "consul" {
  source                   = "modules/consul"
  env_name                 = "${var.env_name}"
  stack_name               = "${var.stack_name}"
  aws_region               = "${var.aws_region}"
  vpc_id                   = "${var.vpc_id}"
  consul_server_subnet_ids = "${var.consul_server_subnet_ids}"
  consul_ami_id            = "${var.consul_ami_id}"
  consul_cluster_name      = "${local.consul_cluster_name}"
  consul_num_servers       = "${var.consul_num_servers}"
  instance_type            = "${var.consul_instance_type}"
  allowed_ssh_cidr_blocks  = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name             = "${var.ssh_key_name}"
}

module "nomad" {
  source                    = "modules/nomad"
  aws_region                = "${var.aws_region}"
  nomad_ami_id_servers      = "${var.nomad_ami_id_servers}"
  nomad_ami_id_clients      = "${var.nomad_ami_id_clients}"
  consul_ami_id             = "${var.consul_ami_id}"
  ssh_key_name              = "${var.ssh_key_name}"
  vpc_id                    = "${var.vpc_id}"
  nomad_server_subnet_ids   = "${var.nomad_server_subnet_ids}"
  unique_postfix            = "${var.unique_postfix}"
  nomad_cluster_name        = "${var.nomad_cluster_name}"
  consul_cluster_name       = "${local.consul_cluster_name}"
  env_name                  = "${var.env_name}"
  alb_public_services_arn   = "${var.alb_public_services_arn}"
  alb_backoffice_nomad_arn  = "${var.alb_backoffice_nomad_arn}"
  alb_backoffice_consul_arn = "${var.alb_backoffice_consul_arn}"
  alb_backoffice_fabio_arn  = "${var.alb_backoffice_fabio_arn}"
  num_nomad_servers         = "${var.num_nomad_servers}"
  num_nomad_clients         = "${var.num_nomad_clients}"
  instance_type_server      = "${var.instance_type_server}"
  instance_type_client      = "${var.instance_type_client}"
}
