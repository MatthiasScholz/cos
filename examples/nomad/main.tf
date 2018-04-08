locals {
  aws_region               = "us-east-1"
  stack_name               = "COS"
  env_name                 = "playground"
  consul_ami_id            = "ami-a23feadf"
  nomad_ami_id             = "ami-a23feadf"
  consul_cluster_tag_key   = "consul-servers"
  consul_cluster_tag_value = "${local.stack_name}-SDCFG-consul-${random_pet.unicorn.id}"
}

provider "aws" {
  profile = "${var.deploy_profile}"
  region  = "${local.aws_region}"
}

resource "random_pet" "unicorn" {
  # NOTE: Length 1 used to avoid problems with the different delimiter requierements in AWS. Nevertheless 1 should be enough.
  length = 1
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
  ami_id     = "${local.consul_ami_id}"

  ## optional parameters
  aws_region              = "${local.aws_region}"
  env_name                = "${local.env_name}"
  stack_name              = "${local.stack_name}"
  cluster_tag_key         = "${local.consul_cluster_tag_key}"
  cluster_tag_value       = "${local.consul_cluster_tag_value}"
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name            = "kp-us-east-1-playground-instancekey"
}

module "nomad" {
  source = "../../modules/nomad"

  ## required parameters
  vpc_id                   = "${data.aws_vpc.default.id}"
  subnet_ids               = "${data.aws_subnet_ids.all.ids}"
  ami_id                   = "${local.nomad_ami_id}"
  consul_cluster_tag_key   = "${local.consul_cluster_tag_key}"
  consul_cluster_tag_value = "${local.consul_cluster_tag_value}"

  ## optional parameters
  aws_region              = "${local.aws_region}"
  env_name                = "${local.env_name}"
  stack_name              = "${local.stack_name}"
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name            = "kp-us-east-1-playground-instancekey"
  instance_type           = "t2.micro"
  unique_postfix          = "-${random_pet.unicorn.id}"
  datacenter_name         = "leader"

  node_scaling_cfg = {
    "min"              = 3
    "max"              = 3
    "desired_capacity" = 3
  }
}
