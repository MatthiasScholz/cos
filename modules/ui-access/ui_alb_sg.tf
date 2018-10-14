resource "aws_security_group" "sg_ui_alb" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.stack_name}-ui-alb${var.unique_postfix}"
  description = "Security group that allows ingress access to uis in backoffice."

  tags {
    Name = "${var.stack_name}-ui-alb${var.unique_postfix}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  keys = "${keys(var.allowed_cidr_blocks_for_ui_alb)}"
}

# INGRESS UI access rules
resource "aws_security_group_rule" "sgr_alb_ig_ui" {
  count             = "${length(local.keys)}"
  description       = "${element(local.keys,count.index)}: UI - igress ${local.listener_port}"
  type              = "ingress"
  from_port         = "${local.listener_port}"
  to_port           = "${local.listener_port}"
  protocol          = "tcp"
  cidr_blocks       = ["${lookup(var.allowed_cidr_blocks_for_ui_alb,element(local.keys,count.index),"0.0.0.0/32")}"]
  security_group_id = "${aws_security_group.sg_ui_alb.id}"
}

# EGRESS Grants access for all tcp
resource "aws_security_group_rule" "sgr_alb_egAll_ui" {
  type        = "egress"
  description = "UI - egress all"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_ui_alb.id}"
}
