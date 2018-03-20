module "networking" {
  source   = "modules/networking"
  region   = "${var.aws_region}"
  env_name = "${var.env_name}"
  unique_postfix = "${var.unique_postfix}"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

module "nomad" {
  source                  = "modules/nomad"
  aws_region              = "${var.aws_region}"
  nomad_ami_id            = "${var.nomad_ami_id}"
  consul_ami_id           = "${var.consul_ami_id}"
  ssh_key_name            = "${var.ssh_key_name}"
  vpc_id                  = "${module.networking.vpc_id}"
  nomad_server_subnet_ids = "${module.networking.subnet_ids}"
  unique_postfix          = "${var.unique_postfix}"
  nomad_cluster_name      = "${var.nomad_cluster_name}"
  consul_cluster_name     = "${var.consul_cluster_name}"
  env_name                = "${var.env_name}"
  alb_public_services_arn = "${module.networking.alb_public_services_arn}"
  alb_backoffice_arn      = "${module.networking.alb_public_services_arn}"
}
