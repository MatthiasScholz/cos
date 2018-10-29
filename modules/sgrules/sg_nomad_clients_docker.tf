# Security Group rules for nomad-clients

# rule granting access to public services data-center for docker ports
# 20000 ... 32000 tcp
resource "aws_security_group_rule" "sgr_to_public_services_docker" {
  type              = "ingress"
  description       = "Grants access on docker ports"
  from_port         = 20000
  to_port           = 32000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_public_services_dc}"
}

# rule granting access to private services data-center for docker ports
# 20000 ... 32000 tcp
resource "aws_security_group_rule" "sgr_to_private_services_docker" {
  type              = "ingress"
  description       = "Grants access on docker ports"
  from_port         = 20000
  to_port           = 32000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_private_services_dc}"
}

# rule granting access to content-conncetor data-center for docker ports
# 20000 ... 32000 tcp
resource "aws_security_group_rule" "sgr_to_content_connector_docker" {
  type              = "ingress"
  description       = "Grants access on docker ports"
  from_port         = 20000
  to_port           = 32000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_content_connector_dc}"
}

# rule granting access to backoffice data-center for docker ports
# 20000 ... 32000 tcp
resource "aws_security_group_rule" "sgr_to_backoffice_docker" {
  type              = "ingress"
  description       = "Grants access on docker ports"
  from_port         = 20000
  to_port           = 32000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_backoffice_dc}"
}

# rule granting access to public services data-center for docker ports
# 20000 ... 32000 udp
resource "aws_security_group_rule" "sgr_to_public_services_docker_udp" {
  type              = "ingress"
  description       = "Grants access on docker ports for udp"
  from_port         = 20000
  to_port           = 32000
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_public_services_dc}"
}

# rule granting access to private services data-center for docker ports
# 20000 ... 32000 udp
resource "aws_security_group_rule" "sgr_to_private_services_docker_udp" {
  type              = "ingress"
  description       = "Grants access on docker ports for udp"
  from_port         = 20000
  to_port           = 32000
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_private_services_dc}"
}

# rule granting access to content-conncetor data-center for docker ports
# 20000 ... 32000 udp
resource "aws_security_group_rule" "sgr_to_content_connector_docker_udp" {
  type              = "ingress"
  description       = "Grants access on docker ports for udp"
  from_port         = 20000
  to_port           = 32000
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_content_connector_dc}"
}

# rule granting access to backoffice data-center for docker ports
# 20000 ... 32000 udp
resource "aws_security_group_rule" "sgr_to_backoffice_docker_udp" {
  type              = "ingress"
  description       = "Grants access on docker ports for udp"
  from_port         = 20000
  to_port           = 32000
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_backoffice_dc}"
}
