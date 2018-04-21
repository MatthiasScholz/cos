locals {
  aws_region = "us-east-1"
  stack_name = "COS"
  env_name   = "playground"
  ami_id     = "ami-1853ac65" # Amazon Linux AMI 2017.09.1 (HVM)
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

module "bastion" {
  source = "../../modules/bastion"

  ## required parameters
  vpc_id       = "${data.aws_vpc.default.id}"
  subnet_id    = "${element(data.aws_subnet_ids.all.ids,0)}"
  ami_id       = "${local.ami_id}"
  ssh_key_name = "kp-us-east-1-playground-instancekey"

  ## optional parameters
  aws_region = "${local.aws_region}"
  env_name   = "${local.env_name}"
  stack_name = "${local.stack_name}"

  allowed_ssh_cidr_blocks = {
    "all" = "0.0.0.0/0"
  }

  instance_type  = "t2.micro"
  unique_postfix = "-${random_pet.unicorn.id}"
}
