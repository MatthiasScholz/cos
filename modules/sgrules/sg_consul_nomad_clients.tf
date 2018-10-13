# INGRESS (Consul ports see: https://www.consul.io/docs/agent/options.html in section 'Ports Used') 
# Server RPC (Default 8300). This is used by servers to handle incoming requests from other agents. TCP only.
# Serf LAN (Default 8301). This is used to handle gossip in the LAN. Required by all agents. TCP and UDP.
# Serf WAN (Default 8302). This is used by servers to gossip over the WAN to other servers. TCP and UDP. 
## As of Consul 0.8, it is recommended to enable connection between servers through port 8302 
## for both TCP and UDP on the LAN interface as well for the WAN Join Flooding feature. See also: Consul 0.8.0 CHANGELOG and GH-3058
# HTTP API (Default 8500). This is used by clients to talk to the HTTP API. TCP only.
# DNS Interface (Default 8600). Used to resolve DNS queries. TCP and UDP.

# rule granting access from public-services data-center consul on ports
# 8300...8302 tcp
# [client>server] RCP, Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_public_services_to_consul_tcp" {
  type                     = "ingress"
  description              = "Grants access from public-services (rcp, serf: lan, wan - tcp)"
  from_port                = 8300
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_public_services_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from private-services data-center consul on ports
# 8300...8302 tcp
# [client>server] RCP, Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_private_services_to_consul_tcp" {
  type                     = "ingress"
  description              = "Grants access from private-services (rcp, serf: lan, wan - tcp)"
  from_port                = 8300
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_private_services_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from content-connector data-center consul on ports
# 8300...8302 tcp
# [client>server] RCP, Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_content_connector_to_consul_tcp" {
  type                     = "ingress"
  description              = "Grants access from content-connector (rcp, serf: lan, wan - tcp)"
  from_port                = 8300
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_content_connector_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from backoffice data-center consul on ports
# 8300...8302 tcp
# [client>server] RCP, Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_backoffice_to_consul_tcp" {
  type                     = "ingress"
  description              = "Grants access from backoffice (rcp, serf: lan, wan - tcp)"
  from_port                = 8300
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_backoffice_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from public-services data-center consul on ports
# 8301...8302 udp
# [client>server] RCP, Serf LAN and WAN, udp
resource "aws_security_group_rule" "sgr_public_services_to_consul_udp" {
  type                     = "ingress"
  description              = "Grants access from public-services (rcp, serf: lan, wan - udp)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_public_services_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from private-services data-center consul on ports
# 8301...8302 udp
# [client>server] RCP, Serf LAN and WAN, udp
resource "aws_security_group_rule" "sgr_private_services_to_consul_udp" {
  type                     = "ingress"
  description              = "Grants access from private-services (rcp, serf: lan, wan - udp)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_private_services_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from content-connector data-center consul on ports
# 8301...8302 udp
# [client>server] RCP, Serf LAN and WAN, udp
resource "aws_security_group_rule" "sgr_content_connector_to_consul_udp" {
  type                     = "ingress"
  description              = "Grants access from content-connector (rcp, serf: lan, wan - udp)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_content_connector_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from backoffice data-center consul on ports
# 8301...8302 udp
# [client>server] RCP, Serf LAN and WAN, udp
resource "aws_security_group_rule" "sgr_backoffice_to_consul_udp" {
  type                     = "ingress"
  description              = "Grants access from backoffice (rcp, serf: lan, wan - udp)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_backoffice_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from public-services data-center consul on ports
# 8500 tcp
# [client>server] HTTP API
resource "aws_security_group_rule" "sgr_public_services_to_consul_http" {
  type                     = "ingress"
  description              = "Grants access from public-services http"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_public_services_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from private-services data-center consul on ports
# 8500 tcp
# [client>server] HTTP API
resource "aws_security_group_rule" "sgr_private_services_to_consul_http" {
  type                     = "ingress"
  description              = "Grants access from private-services http"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_private_services_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from content-connector data-center consul on ports
# 8500 tcp
# [client>server] HTTP API
resource "aws_security_group_rule" "sgr_content_connector_to_consul_http" {
  type                     = "ingress"
  description              = "Grants access from content-connector http"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_content_connector_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from backoffice data-center consul on ports
# 8500 tcp
# [client>server] HTTP API
resource "aws_security_group_rule" "sgr_backoffice_to_consul_http" {
  type                     = "ingress"
  description              = "Grants access from backoffice http"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_backoffice_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from public-services data-center consul on ports
# 8600 tcp
# [client>server] DNS, TCP
resource "aws_security_group_rule" "sgr_public_services_to_consul_dns_tcp" {
  type                     = "ingress"
  description              = "Grants access from public-services (dns tcp)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_public_services_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from private-services data-center consul on ports
# 8600 tcp
# [client>server] DNS, TCP
resource "aws_security_group_rule" "sgr_private_services_to_consul_dns_tcp" {
  type                     = "ingress"
  description              = "Grants access from private-services (dns tcp)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_private_services_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from content-connector data-center consul on ports
# 8600 tcp
# [client>server] DNS, TCP
resource "aws_security_group_rule" "sgr_content_connector_to_consul_dns_tcp" {
  type                     = "ingress"
  description              = "Grants access from content-connector (dns tcp)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_content_connector_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from backoffice data-center consul on ports
# 8600 tcp
# [client>server] DNS, TCP
resource "aws_security_group_rule" "sgr_backoffice_to_consul_dns_tcp" {
  type                     = "ingress"
  description              = "Grants access from backoffice (dns tcp)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_backoffice_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from public-services data-center consul on ports
# 8600 udp
# [client>server] DNS, udp
resource "aws_security_group_rule" "sgr_public_services_to_consul_dns_udp" {
  type                     = "ingress"
  description              = "Grants access from public-services (dns udp)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_public_services_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from private-services data-center consul on ports
# 8600 udp
# [client>server] DNS, udp
resource "aws_security_group_rule" "sgr_private_services_to_consul_dns_udp" {
  type                     = "ingress"
  description              = "Grants access from private-services (dns udp)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_private_services_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from content-connector data-center consul on ports
# 8600 udp
# [client>server] DNS, udp
resource "aws_security_group_rule" "sgr_content_connector_to_consul_dns_udp" {
  type                     = "ingress"
  description              = "Grants access from content-connector (dns udp)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_content_connector_dc}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from backoffice data-center consul on ports
# 8600 udp
# [client>server] DNS, udp
resource "aws_security_group_rule" "sgr_backoffice_to_consul_dns_udp" {
  type                     = "ingress"
  description              = "Grants access from backoffice (dns udp)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_backoffice_dc}"
  security_group_id        = "${var.sg_id_consul}"
}
