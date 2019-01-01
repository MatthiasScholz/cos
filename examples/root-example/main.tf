locals {
  ami_id_bastion = "ami-1853ac65" # Amazon Linux AMI 2017.09.1 (HVM)

  # cidr blocks allowed for ssh and alb access
  allowed_cidr_blocks = {
    "all"    = "0.0.0.0/0"
    "shared" = "10.49.0.0/16"
  }
}

provider "aws" {
  profile = "${var.deploy_profile}"
  region  = "${var.aws_region}"
}

resource "random_pet" "unicorn" {
  # NOTE: Length 1 used to avoid problems with the different delimiter requierements in AWS. Nevertheless 1 should be enough.
  length = 1
}

module "networking" {
  source         = "../../modules/networking"
  region         = "${var.aws_region}"
  env_name       = "${var.env_name}"
  unique_postfix = "-${random_pet.unicorn.id}"
  az_postfixes   = ["a", "b"]
}

module "bastion" {
  source = "../../modules/bastion"

  ## required parameters
  vpc_id       = "${module.networking.vpc_id}"
  subnet_id    = "${element(module.networking.public_subnet_ids,0)}"
  ami_id       = "${local.ami_id_bastion}"
  ssh_key_name = "${var.ssh_key_name}"

  ## optional parameters
  aws_region              = "${var.aws_region}"
  env_name                = "${var.env_name}"
  stack_name              = "${var.stack_name}"
  allowed_ssh_cidr_blocks = "${local.allowed_cidr_blocks}"
  instance_type           = "t2.micro"
  unique_postfix          = "-${random_pet.unicorn.id}"
}

module "nomad-infra" {
  source = "../../"

  # [General] Required variables
  aws_region     = "${var.aws_region}"
  vpc_id         = "${module.networking.vpc_id}"
  alb_subnet_ids = "${module.networking.public_subnet_ids}"

  # HACK: Use an http listener here to avoid the need to create a certificate.
  # In a production environmant you should pass in a https listener instead.
  alb_ingress_https_listener_arn = "${module.networking.alb_ingress_http_listener_arn}"

  alb_backoffice_https_listener_arn = "${module.networking.alb_backoffice_https_listener_arn}"
  attach_backoffice_alb_listener    = true

  # [Nomad] Required variables
  nomad_ami_id_servers                       = "${var.nomad_ami_id_servers}"
  nomad_ami_id_clients                       = "${var.nomad_ami_id_clients}"
  nomad_server_subnet_ids                    = "${module.networking.backoffice_subnet_ids}"
  nomad_clients_public_services_subnet_ids   = "${module.networking.services_subnet_ids}"
  nomad_clients_private_services_subnet_ids  = "${module.networking.services_subnet_ids}"
  nomad_clients_content_connector_subnet_ids = "${module.networking.content_connector_subnet_ids}"
  nomad_clients_backoffice_subnet_ids        = "${module.networking.backoffice_subnet_ids}"

  # [Consul] Required variables
  consul_ami_id            = "${var.nomad_ami_id_servers}"
  consul_server_subnet_ids = "${module.networking.backoffice_subnet_ids}"

  # [General] Optional variables
  stack_name              = "${var.stack_name}"
  env_name                = "${var.env_name}"
  unique_postfix          = "-${random_pet.unicorn.id}"
  instance_type_server    = "t2.micro"
  ssh_key_name            = "${var.ssh_key_name}"
  allowed_ssh_cidr_blocks = ["${values(local.allowed_cidr_blocks)}"]

  allowed_cidr_blocks_for_ui_alb = "${local.allowed_cidr_blocks}"

  # INFO: uncomment the following two lines if you want to deploy the cluster having https endpoints 
  # for the ui-albs (nomad-ui, consul-ui and fabio-ui).
  # Keep in mind that you have to configure the nomad CLI to skip certificate verification in this case
  # because the sample certificate that is used here is just a self signed one which even does not fit the
  # domain by the nomad alb. Short said it is invalid and only in place for testing/ demonstration purposes. 
  #ui_alb_https_listener_cert_arn = "${aws_iam_server_certificate.certificate_alb.arn}"
  #ui_alb_use_https_listener      = true

  # [Nomad] Optional variables
  nomad_server_scaling_cfg                        = "${var.server_scaling_cfg}"
  nomad_private_services_dc_node_cfg              = "${var.nomad_dc_node_cfg}"
  nomad_public_services_dc_node_cfg               = "${var.nomad_dc_node_cfg}"
  nomad_content_connector_dc_node_cfg             = "${var.nomad_dc_node_cfg}"
  nomad_backoffice_dc_node_cfg                    = "${var.nomad_dc_node_cfg}"
  ebs_block_devices_private_services_dc           = "${var.ebs_block_devices_sample}"
  ebs_block_devices_public_services_dc            = "${var.ebs_block_devices_sample}"
  ebs_block_devices_backoffice_dc                 = "${var.ebs_block_devices_sample}"
  ebs_block_devices_content_connector_dc          = "${var.ebs_block_devices_sample}"
  device_to_mount_target_map_public_services_dc   = "${var.device_to_mount_target_map_sample}"
  device_to_mount_target_map_private_services_dc  = "${var.device_to_mount_target_map_sample}"
  device_to_mount_target_map_backoffice_dc        = "${var.device_to_mount_target_map_sample}"
  device_to_mount_target_map_content_connector_dc = "${var.device_to_mount_target_map_sample}"
  additional_instance_tags_public_services_dc     = "${var.additional_instance_tags_sample}"
  additional_instance_tags_private_services_dc    = "${var.additional_instance_tags_sample}"
  additional_instance_tags_backoffice_dc          = "${var.additional_instance_tags_sample}"
  additional_instance_tags_content_connector_dc   = "${var.additional_instance_tags_sample}"
  # [Consul] Optional variables
  consul_num_servers   = 3
  consul_instance_type = "t2.micro"
}
