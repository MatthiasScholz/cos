locals {
  ami_id_server  = "ami-a23feadf"
  ami_id_clients = "ami-e5e34798"
  ami_id_bastion = "ami-1853ac65"                        # Amazon Linux AMI 2017.09.1 (HVM)
  env_name       = "playground"
  aws_region     = "us-east-1"
  stack_name     = "COS"
  ssh_key_name   = "kp-us-east-1-playground-instancekey"

  allowed_ssh_cidr_blocks = {
    "pcc_dev"  = "80.146.215.90/32"
    "thomas"   = "95.90.215.115/32"
    "matthias" = "89.247.74.78/32"
  }
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

module "bastion" {
  source = "../../modules/bastion"

  ## required parameters
  vpc_id       = "${module.networking.vpc_id}"
  subnet_id    = "${element(module.networking.public_subnet_ids,0)}"
  ami_id       = "${local.ami_id_bastion}"
  ssh_key_name = "${local.ssh_key_name}"

  ## optional parameters
  aws_region              = "${local.aws_region}"
  env_name                = "${local.env_name}"
  stack_name              = "${local.stack_name}"
  allowed_ssh_cidr_blocks = "${local.allowed_ssh_cidr_blocks}"
  instance_type           = "t2.micro"
  unique_postfix          = "-${random_pet.unicorn.id}"
}

module "nomad-infra" {
  source = "../../"

  # [General] Required variables
  aws_region              = "${local.aws_region}"
  vpc_id                  = "${module.networking.vpc_id}"
  alb_subnet_ids          = "${module.networking.public_subnet_ids}"
  alb_public_services_arn = "${module.networking.alb_public_services_arn}"

  # [Nomad] Required variables
  nomad_ami_id_servers                       = "${local.ami_id_server}"
  nomad_ami_id_clients                       = "${local.ami_id_clients}"
  nomad_server_subnet_ids                    = "${module.networking.backoffice_subnet_ids}"
  nomad_clients_public_services_subnet_ids   = "${module.networking.services_subnet_ids}"
  nomad_clients_private_services_subnet_ids  = "${module.networking.services_subnet_ids}"
  nomad_clients_content_connector_subnet_ids = "${module.networking.content_connector_subnet_ids}"
  nomad_clients_backoffice_subnet_ids        = "${module.networking.backoffice_subnet_ids}"

  # [Consul] Required variables
  consul_ami_id            = "${local.ami_id_server}"
  consul_server_subnet_ids = "${module.networking.backoffice_subnet_ids}"

  # [General] Optional variables
  stack_name              = "${local.stack_name}"
  env_name                = "${local.env_name}"
  unique_postfix          = "-${random_pet.unicorn.id}"
  instance_type_server    = "t2.micro"
  instance_type_client    = "t2.small"
  ssh_key_name            = "${local.ssh_key_name}"
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  allowed_cidr_blocks_for_ui_alb = "${local.allowed_ssh_cidr_blocks}"

  # [Nomad] Optional variables
  nomad_server_scaling_cfg = {
    "min"              = 3
    "max"              = 3
    "desired_capacity" = 3
  }

  nomad_client_scaling_cfg = {
    "min"              = 1
    "max"              = 1
    "desired_capacity" = 1
  }

  # [Consul] Optional variables
  consul_num_servers   = 3
  consul_instance_type = "t2.micro"
}
