# SG granting access of the nomad servers to this datacenter nodes
resource "aws_security_group" "sg_nomad_server_access" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.stack_name}-${var.datacenter_name}-nomad-server-access${var.unique_postfix}"
  description = "Security group that allows ingress access for the nomad-servers."

  tags {
    Name = "${var.stack_name}-${var.datacenter_name}-nomad-server-access${var.unique_postfix}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# INGRESS
# rule that grants TCP ingress access from nomad-server to nomad-clients
resource "aws_security_group_rule" "sgr_client_tcp_ig_from_nomad_server" {
  type                     = "ingress"
  description              = "tcp ingress from Nomad Servers"
  from_port                = 4646
  to_port                  = 4648
  protocol                 = "tcp"
  source_security_group_id = "${var.server_sg_id}"
  security_group_id        = "${aws_security_group.sg_nomad_server_access.id}"
}

# rule that grants UDP ingress access from nomad-server to nomad-clients
resource "aws_security_group_rule" "sgr_client_udp_ig_from_nomad_server" {
  type                     = "ingress"
  description              = "udp ingress from Nomad Servers"
  from_port                = 4648
  to_port                  = 4648
  protocol                 = "udp"
  source_security_group_id = "${var.server_sg_id}"
  security_group_id        = "${aws_security_group.sg_nomad_server_access.id}"
}

# EGRESS
# grants access for all tcp but only to the services subnet
resource "aws_security_group_rule" "sgr_client_eg_all" {
  description = "Egress all"
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_nomad_server_access.id}"
}

# Inject rule into sg of nomad server to get access over ports 4646..4648
resource "aws_security_group_rule" "sgr_client_to_server_ig4646_4648" {
  type        = "ingress"
  description = "igress tcp from clients 4646-4648"
  from_port   = 4646
  to_port     = 4648
  protocol    = "tcp"

  source_security_group_id = "${aws_security_group.sg_nomad_server_access.id}"
  security_group_id        = "${var.server_sg_id}"
}

# Inject rule into sg of nomad server to get access over ports 4648
resource "aws_security_group_rule" "sgr_client_to_server_ig4648" {
  type        = "ingress"
  description = "igress udp from clients 4648"
  from_port   = 4648
  to_port     = 4648
  protocol    = "udp"

  source_security_group_id = "${aws_security_group.sg_nomad_server_access.id}"
  security_group_id        = "${var.server_sg_id}"
}
