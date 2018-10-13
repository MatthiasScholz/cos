# Security Group rules for nomad-clients

# rule granting access on igress-ports to public services data-center on ports
# 9998 ... 9999
resource "aws_security_group_rule" "sgr_public_services_ig_999x" {
  type              = "ingress"
  description       = "Grants access from igress controller."
  from_port         = 9998
  to_port           = 9999
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_public_services_dc}"
}

# rule granting access on igress-ports to private services data-center on ports
# 9998 ... 9999
resource "aws_security_group_rule" "sgr_private_services_ig_999x" {
  type              = "ingress"
  description       = "Grants access from igress controller."
  from_port         = 9998
  to_port           = 9999
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_private_services_dc}"
}


# rule granting access on igress-ports to content-connector data-center on ports
# 9998 ... 9999
resource "aws_security_group_rule" "sgr_content_connector_ig_999x" {
  type              = "ingress"
  description       = "Grants access from igress controller."
  from_port         = 9998
  to_port           = 9999
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_content_connector_dc}"
}


# rule granting access on igress-ports to backoffice services data-center on ports
# 9998 ... 9999
resource "aws_security_group_rule" "sgr_backoffice_ig_999x" {
  type              = "ingress"
  description       = "Grants access from igress controller."
  from_port         = 9998
  to_port           = 9999
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.sg_id_backoffice_dc}"
}
