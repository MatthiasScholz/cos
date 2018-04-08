# Bastion module

This module contains terrafrom code for setting up a bastion server.

## How to use this module

At [examples/bastion](../../examples/bastion/) there is a full running example (incl. minimal needed environment).

```bash
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

module "bastion" {
  source = "../../modules/bastion"
  vpc_id    = "${data.aws_vpc.default.id}"
  subnet_id = "${element(data.aws_subnet_ids.all.ids,0)}"
  ami_id    = ...
  ssh_key_name   = ...

  allowed_ssh_cidr_blocks = {
    "all" = "0.0.0.0/0"
  }

}

```