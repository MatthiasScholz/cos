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

resource "aws_security_group" "sg_sample" {
  name_prefix = "sg_sample_"
  vpc_id      = "${data.aws_vpc.default.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_all_inbound" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.sg_sample.id}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.sg_sample.id}"
}

resource "aws_autoscaling_group" "asg_sample" {
  launch_configuration = "${aws_launch_configuration.lc_sample.name}"
  name_prefix          = "asg-sample-"
  vpc_zone_identifier  = ["${data.aws_subnet_ids.all.ids}"]
  min_size             = "1"
  max_size             = "1"
}

resource "aws_launch_configuration" "lc_sample" {
  name_prefix                 = "lc-sample-"
  image_id                    = "ami-43a15f3e"                             # Ubuntu Server 16.04 LTS (HVM)
  instance_type               = "t2.micro"
  user_data                   = "${data.template_file.user_data.rendered}"
  key_name                    = "kp-us-east-1-playground-instancekey"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.sg_sample.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    nomad_ui_port  = 4646
    consul_ui_port = 8500
    fabio_ui_port  = 9998
  }
}

module "ui-access" {
  source = "../../modules/ui-access"

  ## required parameters
  vpc_id                 = "${data.aws_vpc.default.id}"
  subnet_ids             = "${data.aws_subnet_ids.all.ids}"
  nomad_server_asg_name  = "${aws_autoscaling_group.asg_sample.name}"
  consul_server_asg_name = "${aws_autoscaling_group.asg_sample.name}"
  fabio_server_asg_name  = "${aws_autoscaling_group.asg_sample.name}"

  ## optional parameters
  aws_region = "${local.aws_region}"
  env_name   = "${local.env_name}"
  stack_name = "${local.stack_name}"
}
