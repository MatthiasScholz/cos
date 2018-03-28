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

data "aws_iam_policy_document" "ipd_instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iamr_sample_instance_role" {
  name_prefix        = "nomad-sample-inst-role"
  assume_role_policy = "${data.aws_iam_policy_document.ipd_instance_role.json}"
}

module "consul" {
  source                    = "../../modules/consul"
  aws_region                = "${var.aws_region}"
  consul_ami_id             = "${var.consul_ami_id}"
  env_name                  = "playground"
  nomad_servers_iam_role_id = "${aws_iam_role.iamr_sample_instance_role.id}"
  nomad_clients_iam_role_id = "${aws_iam_role.iamr_sample_instance_role.id}"
  vpc_id                    = "${data.aws_vpc.default.id}"
  consul_server_subnet_ids  = "${data.aws_subnet_ids.all.ids}"
}
