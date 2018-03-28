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

module "ui-access" {
  source = "../../modules/ui-access"

  ## required parameters
  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.all.ids}"

  ## optional parameters
  aws_region     = "${local.aws_region}"
  env_name       = "${local.env_name}"
  stack_name     = "${local.stack_name}"
  unique_postfix = "example"
}
