# Security Group rules for nomad-clients grants access from nomad-server to nomad-clients

# rule that grants TCP ingress access from nomad-server to public-services data-center on ports
# 4646 ... http api
# 4647 ... rcp, for communication between clients and servers
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_server_to_public_services_tcp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (tcp)."
  from_port                = 4646
  to_port                  = 4648
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_public_services_dc}"
}

# rule that grants TCP ingress access from nomad-server to private-services data-center on ports
# 4646 ... http api
# 4647 ... rcp, for communication between clients and servers
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_server_to_private_services_tcp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (tcp)."
  from_port                = 4646
  to_port                  = 4648
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_private_services_dc}"
}

# rule that grants TCP ingress access from nomad-server to content-connector data-center on ports
# 4646 ... http api
# 4647 ... rcp, for communication between clients and servers
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_server_to_content_connector_tcp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (tcp)."
  from_port                = 4646
  to_port                  = 4648
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_content_connector_dc}"
}

# rule that grants TCP ingress access from nomad-server to backoffice data-center on ports
# 4646 ... http api
# 4647 ... rcp, for communication between clients and servers
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_server_to_backoffice_tcp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (tcp)."
  from_port                = 4646
  to_port                  = 4648
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_backoffice_dc}"
}

# rule that grants UDP ingress access from nomad-server to public-services data-center on ports
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_server_to_public_services_udp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (udp)."
  from_port                = 4648
  to_port                  = 4648
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_public_services_dc}"
}

# rule that grants UDP ingress access from nomad-server to private-services data-center on ports
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_server_to_private_services_udp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (udp)."
  from_port                = 4648
  to_port                  = 4648
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_private_services_dc}"
}

# rule that grants UDP ingress access from nomad-server to content-connector data-center on ports
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_server_to_content_connector_udp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (udp)."
  from_port                = 4648
  to_port                  = 4648
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_content_connector_dc}"
}

# rule that grants UDP ingress access from nomad-server to backoffice data-center on ports
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_server_to_backoffice_udp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (udp)."
  from_port                = 4648
  to_port                  = 4648
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_backoffice_dc}"
}
