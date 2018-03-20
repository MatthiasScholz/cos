module "networking" {
  source = "modules/networking"
  region = "${var.aws_region}"
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
  nomad_ami_id            = "ami-fb94c510"
  consul_ami_id           = "ami-fb94c510"
  ssh_key_name            = "kp_instances"
  vpc_id                  = "${module.networking.vpc_id}"
  nomad_server_subnet_ids = "${module.networking.subnet_ids}"
}
