resource "aws_security_group" "sg_public_services_alb" {
  vpc_id      = "${aws_vpc.vpc_main.id}"
  name        = "${var.stack_name}-ingress${var.unique_postfix}"
  description = "security group that allows ingress access to everyone."

  tags {
    Name = "${var.stack_name}-ingress${var.unique_postfix}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# INGRESS for everyone
resource "aws_security_group_rule" "sgr_alb_ig_http" {
  type              = "ingress"
  description       = "Ingress port 80"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_services_alb.id}"
}

resource "aws_security_group_rule" "sgr_alb_ig_https" {
  type              = "ingress"
  description       = "Ingress port 443"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_services_alb.id}"
}

# grants access for all tcp but only to the services subnet
resource "aws_security_group_rule" "sgr_alb_egAll_server" {
  type        = "egress"
  description = "Egress all tcp"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_public_services_alb.id}"
}
