locals {
  ami_id_server       = "ami-a23feadf"
  ami_id_clients      = "ami-e5e34798"
  consul_cluster_name = "consul-example"
  nomad_cluster_name  = "nomad-example"
  env_name            = "playground"
  aws_region          = "us-east-1"
}

provider "aws" {
  profile = "${var.deploy_profile}"
  region  = "${local.aws_region}"
}

resource "random_pet" "unicorn" {
  # NOTE: Length 1 used to avoid problems with the different delimiter requierements in AWS. Nevertheless 1 should be enough.
  length = 1
}

module "networking" {
  source         = "../../modules/networking"
  region         = "${local.aws_region}"
  env_name       = "${local.env_name}"
  unique_postfix = "-${random_pet.unicorn.id}"
}

module "nomad-infra" {
  source = "../../"

  # Required variables
  aws_region                                 = "${local.aws_region}"
  vpc_id                                     = "${module.networking.vpc_id}"
  nomad_server_subnet_ids                    = "${module.networking.services_subnet_ids}"
  nomad_clients_public_services_subnet_ids   = "${module.networking.services_subnet_ids}"
  nomad_clients_private_services_subnet_ids  = "${module.networking.services_subnet_ids}"
  nomad_clients_content_connector_subnet_ids = "${module.networking.services_subnet_ids}"
  nomad_clients_backoffice_subnet_ids        = "${module.networking.services_subnet_ids}"
  consul_server_subnet_ids                   = "${module.networking.services_subnet_ids}"
  alb_subnet_ids                             = "${module.networking.public_subnet_ids}"
  nomad_ami_id_servers                       = "${local.ami_id_server}"
  nomad_ami_id_clients                       = "${local.ami_id_clients}"
  consul_ami_id                              = "${local.ami_id_server}"
  alb_public_services_arn                    = "${module.networking.alb_public_services_arn}"

  # Optional variables
  stack_name               = "COS"
  env_name                 = "${local.env_name}"
  unique_postfix           = "-${random_pet.unicorn.id}"
  nomad_cluster_name       = "${local.nomad_cluster_name}"
  consul_cluster_name      = "${local.consul_cluster_name}"
  nomad_server_scaling_cfg = "${var.nomad_server_scaling_cfg}"
  nomad_num_clients        = "${var.nomad_num_clients}"
  instance_type_server     = "t2.micro"
  instance_type_client     = "t2.small"
  ssh_key_name             = "kp-us-east-1-playground-instancekey"
  allowed_ssh_cidr_blocks  = ["0.0.0.0/0"]
}
