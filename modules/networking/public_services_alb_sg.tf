resource "aws_security_group" "sg_public_services_alb" {
  vpc_id      = "${aws_vpc.vpc_main.id}"
  name        = "MNG-${var.stack_name}-${var.region}-${var.env_name}-SG-frontend-alb"
  description = "security group that allows ingress access to everyone."

  tags {
    Name = "MNG-${var.stack_name}-${var.region}-${var.env_name}-SG-frontend-alb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# INGRESS for everyone
resource "aws_security_group_rule" "sgr_alb_ig_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_services_alb.id}"
}

# grants access for all tcp but only to the services subnet
resource "aws_security_group_rule" "sgr_alb_egAll_server" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_services_alb.id}"
}

## HACK: Expose nomad client related UIs
## HACK: Expose UI - Fabio
#resource "aws_security_group_rule" "sgr_alb_ig_ui_fabio" {
#  type      = "ingress"
#  from_port = 9998
#  to_port   = 9998
#  protocol  = "tcp"
#
#  # cidr_blocks       = ["${var.allowed_inbound_cidr_blocks}"]
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = "${aws_security_group.sg_public_services_alb.id}"
#}
#
## HACK: Expose UI - Consul
#resource "aws_security_group_rule" "sgr_alb_ig_ui_consul" {
#  type      = "ingress"
#  from_port = 8500
#  to_port   = 8500
#  protocol  = "tcp"
#
#  #cidr_blocks       = ["${var.allowed_inbound_cidr_blocks}"]
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = "${aws_security_group.sg_public_services_alb.id}"
#}
#
## EGRESS
## grants access for all tcp but only to the services subnet
#resource "aws_security_group_rule" "sgr_alb_egAll" {
#  type      = "egress"
#  from_port = 0
#  to_port   = 65535
#  protocol  = "tcp"
#
#  # HACK: not for production
#  cidr_blocks       = ["0.0.0.0/0"]
#  security_group_id = "${aws_security_group.sg_public_services_alb.id}"
#}
#
## HACK: Expose nomad server related UI
#resource "aws_security_group" "sg_public_services_alb_server" {
#  vpc_id      = "${aws_vpc.vpc_main.id}"
#  name        = "MNG-${var.stack_name}-${var.region}-${var.env_name}-SG-frontend-alb-server"
#  description = "security group that allows ingress to nomad server access to everyone."
#
#  tags {
#    Name = "MNG-${var.stack_name}-${var.region}-${var.env_name}-SG-frontend-alb-server"
#  }
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#
## INGRESS
## HACK: Expose nomad server related UI
#resource "aws_security_group_rule" "sgr_alb_ig_ui_nomad" {
#  type      = "ingress"
#  from_port = 4646
#  to_port   = 4646
#  protocol  = "tcp"
#
#  #cidr_blocks       = ["${var.allowed_inbound_cidr_blocks}"]
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = "${aws_security_group.sg_public_services_alb_server.id}"
#}
#

