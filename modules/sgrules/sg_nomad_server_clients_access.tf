# Security Group rules for nomad-server that grants access from nomad-clients to nomad-server 

# rule that grants TCP ingress access from public-services data-center to nomad-server to on ports
# 4646 ... http api
# 4647 ... rcp, for communication between clients and servers
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_public_services_to_server_tcp" {
  type                     = "ingress"
  description              = "Grants access from public-services (tcp)."
  from_port                = 4646
  to_port                  = 4648
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_public_services_dc}"
  security_group_id        = "${var.sg_id_nomad_server}"
}

# rule that grants TCP ingress access from private-services data-center to nomad-server to on ports
# 4646 ... http api
# 4647 ... rcp, for communication between clients and servers
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_private_services_to_server_tcp" {
  type                     = "ingress"
  description              = "Grants access from private-services (tcp)."
  from_port                = 4646
  to_port                  = 4648
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_private_services_dc}"
  security_group_id        = "${var.sg_id_nomad_server}"
}

# rule that grants TCP ingress access from content-connector data-center to nomad-server to on ports
# 4646 ... http api
# 4647 ... rcp, for communication between clients and servers
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_content_connector_to_server_tcp" {
  type                     = "ingress"
  description              = "Grants access from content-connector (tcp)."
  from_port                = 4646
  to_port                  = 4648
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_content_connector_dc}"
  security_group_id        = "${var.sg_id_nomad_server}"
}

# rule that grants TCP ingress access from backoffice data-center to nomad-server to on ports
# 4646 ... http api
# 4647 ... rcp, for communication between clients and servers
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_backoffice_to_server_tcp" {
  type                     = "ingress"
  description              = "Grants access from backoffice (tcp)."
  from_port                = 4646
  to_port                  = 4648
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_backoffice_dc}"
  security_group_id        = "${var.sg_id_nomad_server}"
}

# rule that grants UDP ingress access from public-services data-center to nomad-server to on ports
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_public_services_to_server_udp" {
  type                     = "ingress"
  description              = "Grants access from public-services (udp)."
  from_port                = 4648
  to_port                  = 4648
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_public_services_dc}"
  security_group_id        = "${var.sg_id_nomad_server}"
}

# rule that grants UDP ingress access from private-services data-center to nomad-server to on ports
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_private_services_to_server_udp" {
  type                     = "ingress"
  description              = "Grants access from private-services (udp)."
  from_port                = 4648
  to_port                  = 4648
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_private_services_dc}"
  security_group_id        = "${var.sg_id_nomad_server}"
}

# rule that grants UDP ingress access from content-connector data-center to nomad-server to on ports
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_content_connector_to_server_udp" {
  type                     = "ingress"
  description              = "Grants access from content-connector (udp)."
  from_port                = 4648
  to_port                  = 4648
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_content_connector_dc}"
  security_group_id        = "${var.sg_id_nomad_server}"
}

# rule that grants UDP ingress access from backoffice data-center to nomad-server to on ports
# 4648 ... Serf WAN
resource "aws_security_group_rule" "sgr_backoffice_to_server_udp" {
  type                     = "ingress"
  description              = "Grants access from backoffice (udp)."
  from_port                = 4648
  to_port                  = 4648
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_backoffice_dc}"
  security_group_id        = "${var.sg_id_nomad_server}"
}
