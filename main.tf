locals {
  consul_cluster_tag_key   = "consul-servers"
  consul_cluster_tag_value = "${var.stack_name}-consul${var.unique_postfix}"
}

module "ui-access" {
  source = "modules/ui-access"

  ## required parameters
  vpc_id                         = "${var.vpc_id}"
  subnet_ids                     = "${var.alb_subnet_ids}"
  consul_server_asg_name         = "${module.consul.asg_name_consul_servers}"
  nomad_server_asg_name          = "${module.nomad.asg_name_nomad_servers}"
  fabio_server_asg_name          = "${module.dc-public-services.asg_name}"
  ui_alb_https_listener_cert_arn = "${var.ui_alb_https_listener_cert_arn}"
  ui_alb_use_https_listener      = "${var.ui_alb_use_https_listener}"

  ## optional parameters
  aws_region                     = "${var.aws_region}"
  env_name                       = "${var.env_name}"
  stack_name                     = "${var.stack_name}"
  unique_postfix                 = "${var.unique_postfix}"
  allowed_cidr_blocks_for_ui_alb = "${var.allowed_cidr_blocks_for_ui_alb}"
}

module "consul" {
  source = "modules/consul"

  ## required parameters
  ami_id     = "${var.consul_ami_id}"
  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.consul_server_subnet_ids}"

  ## optional parameters
  env_name                = "${var.env_name}"
  aws_region              = "${var.aws_region}"
  stack_name              = "${var.stack_name}"
  cluster_tag_key         = "${local.consul_cluster_tag_key}"
  cluster_tag_value       = "${local.consul_cluster_tag_value}"
  allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
  num_servers             = "${var.consul_num_servers}"
  instance_type           = "${var.consul_instance_type}"
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
  env_name                       = "${var.env_name}"
  stack_name                     = "${var.stack_name}"
  aws_region                     = "${var.aws_region}"
  instance_type                  = "${lookup(var.nomad_public_services_dc_node_cfg,"instance_type","INVALID")}"
  allowed_ssh_cidr_blocks        = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name                   = "${var.ssh_key_name}"
  datacenter_name                = "public-services"
  unique_postfix                 = "${var.unique_postfix}"
  alb_ingress_http_listener_arn  = "${var.alb_ingress_http_listener_arn}"
  alb_ingress_https_listener_arn = "${var.alb_ingress_https_listener_arn}"
  attach_ingress_alb_listener    = true
  node_scaling_cfg               = "${var.nomad_public_services_dc_node_cfg}"
  ebs_block_devices              = "${var.ebs_block_devices_public_services_dc}"
  device_to_mount_target_map     = "${var.device_to_mount_target_map_public_services_dc}"
  additional_instance_tags       = "${var.additional_instance_tags_public_services_dc}"
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
  env_name                   = "${var.env_name}"
  stack_name                 = "${var.stack_name}"
  aws_region                 = "${var.aws_region}"
  instance_type              = "${lookup(var.nomad_private_services_dc_node_cfg,"instance_type","INVALID")}"
  allowed_ssh_cidr_blocks    = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name               = "${var.ssh_key_name}"
  datacenter_name            = "private-services"
  unique_postfix             = "${var.unique_postfix}"
  node_scaling_cfg           = "${var.nomad_private_services_dc_node_cfg}"
  efs_dns_name               = "${var.efs_dns_name}"
  map_bucket_name            = "${var.map_bucket_name}"
  ebs_block_devices          = "${var.ebs_block_devices_private_services_dc}"
  device_to_mount_target_map = "${var.device_to_mount_target_map_private_services_dc}"
  additional_instance_tags   = "${var.additional_instance_tags_private_services_dc}"
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
  env_name                   = "${var.env_name}"
  stack_name                 = "${var.stack_name}"
  aws_region                 = "${var.aws_region}"
  instance_type              = "${lookup(var.nomad_backoffice_dc_node_cfg,"instance_type","INVALID")}"
  allowed_ssh_cidr_blocks    = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name               = "${var.ssh_key_name}"
  datacenter_name            = "backoffice"
  unique_postfix             = "${var.unique_postfix}"
  node_scaling_cfg           = "${var.nomad_backoffice_dc_node_cfg}"
  ebs_block_devices          = "${var.ebs_block_devices_backoffice_dc}"
  device_to_mount_target_map = "${var.device_to_mount_target_map_backoffice_dc}"
  additional_instance_tags   = "${var.additional_instance_tags_backoffice_dc}"
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
  env_name                   = "${var.env_name}"
  stack_name                 = "${var.stack_name}"
  aws_region                 = "${var.aws_region}"
  instance_type              = "${lookup(var.nomad_content_connector_dc_node_cfg,"instance_type","INVALID")}"
  allowed_ssh_cidr_blocks    = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name               = "${var.ssh_key_name}"
  datacenter_name            = "content-connector"
  unique_postfix             = "${var.unique_postfix}"
  node_scaling_cfg           = "${var.nomad_content_connector_dc_node_cfg}"
  ebs_block_devices          = "${var.ebs_block_devices_content_connector_dc}"
  device_to_mount_target_map = "${var.device_to_mount_target_map_content_connector_dc}"
  additional_instance_tags   = "${var.additional_instance_tags_content_connector_dc}"
}

module "nomad" {
  source = "modules/nomad"

  ## required parameters
  vpc_id                           = "${var.vpc_id}"
  subnet_ids                       = "${var.nomad_server_subnet_ids}"
  ami_id                           = "${var.nomad_ami_id_servers}"
  consul_cluster_tag_key           = "${local.consul_cluster_tag_key}"
  consul_cluster_tag_value         = "${local.consul_cluster_tag_value}"
  consul_cluster_security_group_id = "${module.consul.security_group_id_consul_servers}"

  ## optional parameters
  env_name                = "${var.env_name}"
  stack_name              = "${var.stack_name}"
  aws_region              = "${var.aws_region}"
  instance_type           = "${var.instance_type_server}"
  allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
  ssh_key_name            = "${var.ssh_key_name}"
  node_scaling_cfg        = "${var.nomad_server_scaling_cfg}"
  unique_postfix          = "${var.unique_postfix}"
}

module "sgrules" {
  source                     = "modules/sgrules"
  sg_id_public_services_dc   = "${module.dc-public-services.sg_datacenter_id}"
  sg_id_private_services_dc  = "${module.dc-private-services.sg_datacenter_id}"
  sg_id_content_connector_dc = "${module.dc-content-connector.sg_datacenter_id}"
  sg_id_backoffice_dc        = "${module.dc-backoffice.sg_datacenter_id}"
  sg_id_consul               = "${module.consul.security_group_id_consul_servers}"
  sg_id_nomad_server         = "${module.nomad.security_group_id_nomad_servers}"
  sg_id_ui_alb_nomad         = "${module.ui-access.nomad_ui_alb_sg_id}"
  sg_id_ui_alb_consul        = "${module.ui-access.consul_ui_alb_sg_id}"
}

module "ecr" {
  source = "modules/ecr"

  ecr_repositories = "${var.ecr_repositories}"
}
