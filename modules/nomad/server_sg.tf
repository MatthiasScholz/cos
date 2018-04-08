resource "aws_security_group" "sg_server" {
  vpc_id      = "${var.vpc_id}"
  name        = "${local.base_cluster_name}-SG${var.unique_postfix}"
  description = "Security group for the nomad-server."

  tags {
    Name = "${local.base_cluster_name}-SG${var.unique_postfix}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EGRESS
# grants access for all tcp
resource "aws_security_group_rule" "sgr_server_eg_all" {
  type              = "egress"
  description       = "egress all tcp"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_server.id}"
}
