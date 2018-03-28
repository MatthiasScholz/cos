######################################
# HACK: Expose nomad server related UI
######################################
resource "aws_security_group" "sg_backoffice_nomad_alb" {
  vpc_id      = "${var.vpc_id}"
  name        = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-SG-backoffice-nomad-alb"
  description = "Security group that allows ingress access to everyone."

  tags {
    Name = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-SG-backoffice-nomad-alb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# INGRESS Nomad UI for everyone
resource "aws_security_group_rule" "sgr_alb_ig_ui_nomad" {
  description       = "Nomad UI"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_backoffice_nomad_alb.id}"
}

# EGRESS Grants access for all tcp but only to the backoffice subnet
resource "aws_security_group_rule" "sgr_alb_egAll_nomad" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_backoffice_nomad_alb.id}"
}

########################################
## HACK: Expose UI - Fabio
## HACK: Expose nomad client related UIs
########################################
#resource "aws_security_group" "sg_backoffice_fabio_alb" {
#  vpc_id      = "${aws_vpc.vpc_main.id}"
#  name        = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-SG-backoffice-fabio-alb"
#  description = "Security group that allows ingress access to everyone."
#
#  tags {
#    Name = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-SG-backoffice-fabio-alb"
#  }
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#
## INGRESS Fabio UI for everyone
#resource "aws_security_group_rule" "sgr_alb_ig_ui_fabio" {
#  description = "Fabio UI"
#  type        = "ingress"
#  from_port   = 80
#  to_port     = 80
#  protocol    = "tcp"
#
#  # cidr_blocks       = ["${var.allowed_inbound_cidr_blocks}"]
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = "${aws_security_group.sg_backoffice_fabio_alb.id}"
#}
#
## EGRESS Grants access for all tcp but only to the services subnet
#resource "aws_security_group_rule" "sgr_alb_egAll_fabio" {
#  type      = "egress"
#  from_port = 0
#  to_port   = 65535
#  protocol  = "tcp"
#
#  cidr_blocks       = ["0.0.0.0/0"]
#  security_group_id = "${aws_security_group.sg_backoffice_fabio_alb.id}"
#}
#
############################
## HACK: Expose UI - Consul
############################
#resource "aws_security_group" "sg_backoffice_consul_alb" {
#  vpc_id      = "${aws_vpc.vpc_main.id}"
#  name        = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-SG-backoffice-consul-alb"
#  description = "Security group that allows ingress access to everyone."
#
#  tags {
#    Name = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-SG-backoffice-consul-alb"
#  }
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#
#resource "aws_security_group_rule" "sgr_alb_ig_ui_consul" {
#  description = "Consul UI"
#  type        = "ingress"
#  from_port   = 80
#  to_port     = 80
#  protocol    = "tcp"
#
#  #cidr_blocks       = ["${var.allowed_inbound_cidr_blocks}"]
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = "${aws_security_group.sg_backoffice_consul_alb.id}"
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
#  cidr_blocks       = ["0.0.0.0/0"]
#  security_group_id = "${aws_security_group.sg_backoffice_consul_alb.id}"
#}
#

