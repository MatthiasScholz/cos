locals {
  stack_name = "COS"
  env_name   = "playground"
}

provider "aws" {
  profile = var.deploy_profile
  region  = local.aws_region
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
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "sg_nomad_server" {
  vpc_id      = data.aws_vpc.default.id
  name_prefix = "sg_nomad_server"
  description = "Sample nomad server sg."
}

module "nomad-datacenter" {
  source = "../../modules/nomad-datacenter"

  ## required parameters
  vpc_id                   = data.aws_vpc.default.id
  subnet_ids               = data.aws_subnet_ids.all.ids
  ami_id                   = var.ami_id
  consul_cluster_tag_key   = "consul-servers"
  consul_cluster_tag_value = "${local.stack_name}-${local.env_name}-consul-srv"
  server_sg_id             = aws_security_group.sg_nomad_server.id

  ## optional parameters
  aws_region              = local.aws_region
  env_name                = local.env_name
  stack_name              = local.stack_name
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name            = "${var.ssh_key_name}"
  datacenter_name         = "public-services"
  instance_type           = "t2.micro"
  unique_postfix          = "-${random_pet.unicorn.id}"
  ingress_controller_port = 9999

  additional_instance_tags = [
    {
      "key"                 = "nomad-version"
      "value"               = "vX.Y.Z"
      "propagate_at_launch" = "true"
    },
  ]

  node_scaling_cfg = {
    "min"              = 1
    "max"              = 1
    "desired_capacity" = 1
  }

  ebs_block_devices = [
    {
      "device_name" = "/dev/xvdf"
      "volume_size" = "50"
    },
  ]
}

