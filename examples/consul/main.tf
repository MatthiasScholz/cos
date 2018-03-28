provider "aws" {
  profile = "${var.deploy_profile}"
  region  = "${var.aws_region}"
}

### obtaining default vpc, security group and subnet of the env
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

module "consul" {
  source                   = "../../modules/consul"
  aws_region               = "${var.aws_region}"
  consul_ami_id            = "${var.consul_ami_id}"
  env_name                 = "playground"
  vpc_id                   = "${data.aws_vpc.default.id}"
  consul_server_subnet_ids = "${data.aws_subnet_ids.all.ids}"
}
