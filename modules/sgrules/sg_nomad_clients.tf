# Security Group rules for nomad-clients

# rule granting access from private to public services data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_private_to_public_services_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from private-services dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_private_services_dc}"
  security_group_id        = "${var.sg_id_public_services_dc}"
}

# rule granting access from content-connector to public services data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_content_connector_to_public_services_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from content-connector dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_content_connector_dc}"
  security_group_id        = "${var.sg_id_public_services_dc}"
}

# rule granting access from backoffice to public services data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_backoffice_to_public_services_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from backoffice dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_backoffice_dc}"
  security_group_id        = "${var.sg_id_public_services_dc}"
}

# rule granting access from public to private services data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_public_to_private_services_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from public-services dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_public_services_dc}"
  security_group_id        = "${var.sg_id_private_services_dc}"
}

# rule granting access from content-connector to private services data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_content_connector_to_private_services_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from content-connector dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_content_connector_dc}"
  security_group_id        = "${var.sg_id_private_services_dc}"
}

# rule granting access from backoffice to private services data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_backoffice_to_private_services_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from backoffice dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_backoffice_dc}"
  security_group_id        = "${var.sg_id_private_services_dc}"
}

# rule granting access from public to content-connector data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_public_to_content_connector_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from public-services dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_public_services_dc}"
  security_group_id        = "${var.sg_id_content_connector_dc}"
}

# rule granting access from private-services to content-connector data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_private_to_content_connector_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from private-services dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_private_services_dc}"
  security_group_id        = "${var.sg_id_content_connector_dc}"
}

# rule granting access from backoffice to content-connector data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_backoffice_to_content_connector_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from backoffice dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_backoffice_dc}"
  security_group_id        = "${var.sg_id_content_connector_dc}"
}

# rule granting access from public to backoffice data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_public_to_backoffice_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from public-services dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_public_services_dc}"
  security_group_id        = "${var.sg_id_backoffice_dc}"
}

# rule granting access from content-connector to backoffice data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_content_connector_to_backoffice_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from content-connector dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_content_connector_dc}"
  security_group_id        = "${var.sg_id_backoffice_dc}"
}

# rule granting access from private to backoffice data-center on ports
# 4646 ... http api
# 4648 ... rcp, for communication beteen clients and servers
resource "aws_security_group_rule" "sgr_private_to_backoffice_http_rcp" {
  type                     = "ingress"
  description              = "Grants access from private dc on HTTP and RPC port"
  from_port                = 4646
  to_port                  = 4647
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_private_services_dc}"
  security_group_id        = "${var.sg_id_backoffice_dc}"
}
