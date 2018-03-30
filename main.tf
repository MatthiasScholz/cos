locals {
  consul_cluster_tag_key   = "consul-servers"
  consul_cluster_tag_value = "${var.stack_name}-consul${var.unique_postfix}"
}

module "ui-access" {
  source = "modules/ui-access"

  ## required parameters
  vpc_id                 = "${var.vpc_id}"
  subnet_ids             = "${var.alb_subnet_ids}"
  consul_server_asg_name = "${module.consul.asg_name_consul_servers}"
  nomad_server_asg_name  = "${module.nomad.asg_name_nomad_servers}"
  fabio_server_asg_name  = "${module.dc-public-services.asg_name}"

  ## optional parameters
  aws_region     = "${var.aws_region}"
  env_name       = "${var.env_name}"
  stack_name     = "${var.stack_name}"
  unique_postfix = "${var.unique_postfix}"
}

module "consul" {
  source                  = "modules/consul"
  env_name                = "${var.env_name}"
  stack_name              = "${var.stack_name}"
  aws_region              = "${var.aws_region}"
  vpc_id                  = "${var.vpc_id}"
  subnet_ids              = "${var.consul_server_subnet_ids}"
  ami_id                  = "${var.consul_ami_id}"
  cluster_tag_key         = "${local.consul_cluster_tag_key}"
  cluster_tag_value       = "${local.consul_cluster_tag_value}"
  num_servers             = "${var.consul_num_servers}"
  instance_type           = "${var.consul_instance_type}"
  allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name            = "${var.ssh_key_name}"
}

#### DC: PUBLIC-SERVICES ###################################################
module "dc-public-services" {
  source = "modules/nomad-datacenter"

  ## required parameters
  vpc_id                   = "${var.vpc_id}"
  subnet_ids               = "${var.nomad_clients_public_services_subnet_ids}"
  ami_id                   = "${var.nomad_ami_id_clients}"
  consul_cluster_tag_key   = "${local.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${local.consul_cluster_tag_value}"
  server_sg_id             = "${module.nomad.security_group_id_nomad_servers}"

  ## optional parameters
  env_name                = "${var.env_name}"
  stack_name              = "${var.stack_name}"
  aws_region              = "${var.aws_region}"
  instance_type           = "${var.instance_type_client}"
  allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name            = "${var.ssh_key_name}"
  datacenter_name         = "public-services"
  unique_postfix          = "${var.unique_postfix}"
  alb_ingress_arn         = "${var.alb_public_services_arn}"
  attach_ingress_alb      = true
}

#### DC: PRIVATE-SERVICES ###################################################
module "dc-private-services" {
  source = "modules/nomad-datacenter"

  ## required parameters
  vpc_id                   = "${var.vpc_id}"
  subnet_ids               = "${var.nomad_clients_private_services_subnet_ids}"
  ami_id                   = "${var.nomad_ami_id_clients}"
  consul_cluster_tag_key   = "${local.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${local.consul_cluster_tag_value}"
  server_sg_id             = "${module.nomad.security_group_id_nomad_servers}"

  ## optional parameters
  env_name                = "${var.env_name}"
  stack_name              = "${var.stack_name}"
  aws_region              = "${var.aws_region}"
  instance_type           = "${var.instance_type_client}"
  allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name            = "${var.ssh_key_name}"
  datacenter_name         = "private-services"
  unique_postfix          = "${var.unique_postfix}"
}

#### DC: BACKOFFICE ###################################################
module "dc-backoffice" {
  source = "modules/nomad-datacenter"

  ## required parameters
  vpc_id                   = "${var.vpc_id}"
  subnet_ids               = "${var.nomad_clients_backoffice_subnet_ids}"
  ami_id                   = "${var.nomad_ami_id_clients}"
  consul_cluster_tag_key   = "${local.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${local.consul_cluster_tag_value}"
  server_sg_id             = "${module.nomad.security_group_id_nomad_servers}"

  ## optional parameters
  env_name                = "${var.env_name}"
  stack_name              = "${var.stack_name}"
  aws_region              = "${var.aws_region}"
  instance_type           = "${var.instance_type_client}"
  allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name            = "${var.ssh_key_name}"
  datacenter_name         = "backoffice"
  unique_postfix          = "${var.unique_postfix}"
}

#### DC: CONTENT-CONNECTOR ###################################################
module "dc-content-connector" {
  source = "modules/nomad-datacenter"

  ## required parameters
  vpc_id                   = "${var.vpc_id}"
  subnet_ids               = "${var.nomad_clients_content_connector_subnet_ids}"
  ami_id                   = "${var.nomad_ami_id_clients}"
  consul_cluster_tag_key   = "${local.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${local.consul_cluster_tag_value}"
  server_sg_id             = "${module.nomad.security_group_id_nomad_servers}"

  ## optional parameters
  env_name                = "${var.env_name}"
  stack_name              = "${var.stack_name}"
  aws_region              = "${var.aws_region}"
  instance_type           = "${var.instance_type_client}"
  allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name            = "${var.ssh_key_name}"
  datacenter_name         = "content-connector"
  unique_postfix          = "${var.unique_postfix}"
}

module "nomad" {
  source                   = "modules/nomad"
  env_name                 = "${var.env_name}"
  stack_name               = "${var.stack_name}"
  aws_region               = "${var.aws_region}"
  vpc_id                   = "${var.vpc_id}"
  server_subnet_ids        = "${var.nomad_server_subnet_ids}"
  ami_id_servers           = "${var.nomad_ami_id_servers}"
  ssh_key_name             = "${var.ssh_key_name}"
  unique_postfix           = "${var.unique_postfix}"
  cluster_name             = "${var.nomad_cluster_name}"
  consul_cluster_tag_key   = "${local.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${local.consul_cluster_tag_value}"
  num_servers              = "${var.nomad_num_servers}"
  instance_type_server     = "${var.instance_type_server}"
  allowed_ssh_cidr_blocks  = "${var.allowed_ssh_cidr_blocks}"
}
