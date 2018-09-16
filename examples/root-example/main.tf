locals {
  ami_id_bastion = "ami-1853ac65" # Amazon Linux AMI 2017.09.1 (HVM)

  allowed_ssh_cidr_blocks = {
    "pcc_dev" = "80.146.215.90/32"
    "thomas"  = "95.90.215.116/32"
    "shared"  = "10.49.0.0/16"
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
  allowed_ssh_cidr_blocks = "${local.allowed_ssh_cidr_blocks}"
  instance_type           = "t2.micro"
  unique_postfix          = "-${random_pet.unicorn.id}"
}

module "nomad-infra" {
  source = "../../"

  # [General] Required variables
  aws_region                     = "${var.aws_region}"
  vpc_id                         = "${module.networking.vpc_id}"
  alb_subnet_ids                 = "${module.networking.public_subnet_ids}"
  alb_ingress_http_listener_arn  = "${module.networking.alb_ingress_http_listener_arn}"
  alb_ingress_https_listener_arn = "${module.networking.alb_ingress_https_listener_arn}"

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
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  allowed_cidr_blocks_for_ui_alb = "${local.allowed_ssh_cidr_blocks}"

  # [Nomad] Optional variables
  nomad_server_scaling_cfg            = "${var.server_scaling_cfg}"
  nomad_private_services_dc_node_cfg  = "${var.nomad_dc_node_cfg}"
  nomad_public_services_dc_node_cfg   = "${var.nomad_dc_node_cfg}"
  nomad_content_connector_dc_node_cfg = "${var.nomad_dc_node_cfg}"
  nomad_backoffice_dc_node_cfg        = "${var.nomad_dc_node_cfg}"

  # [Consul] Optional variables
  consul_num_servers   = 3
  consul_instance_type = "t2.micro"
}
