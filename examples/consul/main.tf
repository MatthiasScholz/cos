locals {
  aws_region = "us-east-1"
  stack_name = "COS"
  env_name   = "playground"
}

provider "aws" {
  profile = "${var.deploy_profile}"
  region  = "${local.aws_region}"
}

### obtaining default vpc, security group and subnet of the env
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

module "consul" {
  source = "../../modules/consul"

  ## required parameters
  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.all.ids}"
  ami_id     = "ami-a23feadf"

  ## optional parameters
  aws_region              = "${local.aws_region}"
  env_name                = "${local.env_name}"
  stack_name              = "${local.stack_name}"
  cluster_tag_key         = "consul-servers"
  cluster_tag_value       = "${local.stack_name}-${local.env_name}-consul-srv"
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name            = "kp-us-east-1-playground-instancekey"
}
