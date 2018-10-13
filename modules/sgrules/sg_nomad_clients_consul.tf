# INGRESS (Consul ports see: https://www.consul.io/docs/agent/options.html in section 'Ports Used') 
# Server RPC (Default 8300). This is used by servers to handle incoming requests from other agents. TCP only.
# Serf LAN (Default 8301). This is used to handle gossip in the LAN. Required by all agents. TCP and UDP.
# Serf WAN (Default 8302). This is used by servers to gossip over the WAN to other servers. TCP and UDP. 
## As of Consul 0.8, it is recommended to enable connection between servers through port 8302 
## for both TCP and UDP on the LAN interface as well for the WAN Join Flooding feature. See also: Consul 0.8.0 CHANGELOG and GH-3058
# HTTP API (Default 8500). This is used by clients to talk to the HTTP API. TCP only.
# DNS Interface (Default 8600). Used to resolve DNS queries. TCP and UDP.

# rule granting access from consul to public-services data-center on ports
# 8301...8302 tcp
# [server>client] Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_consul_to_public_services_tcp" {
  type                     = "ingress"
  description              = "Grants access from consul (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_consul}"
  security_group_id        = "${var.sg_id_public_services_dc}"
}

# rule granting access from consul to private-services data-center on ports
# 8301...8302 tcp
# [server>client] Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_consul_to_private_services_tcp" {
  type                     = "ingress"
  description              = "Grants access from consul (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_consul}"
  security_group_id        = "${var.sg_id_private_services_dc}"
}

# rule granting access from consul to content-connector data-center on ports
# 8301...8302 tcp
# [server>client] Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_consul_to_content_connector_tcp" {
  type                     = "ingress"
  description              = "Grants access from consul (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_consul}"
  security_group_id        = "${var.sg_id_content_connector_dc}"
}

# rule granting access from consul to backoffice data-center on ports
# 8301...8302 tcp
# [server>client] Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_consul_to_backoffice_tcp" {
  type                     = "ingress"
  description              = "Grants access from consul (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_consul}"
  security_group_id        = "${var.sg_id_backoffice_dc}"
}

# rule granting access from consul to public-services data-center on ports
# 8301...8302 udp
# [server>client] Serf LAN and WAN, UDP
resource "aws_security_group_rule" "sgr_consul_to_public_services_udp" {
  type                     = "ingress"
  description              = "Grants access from consul (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_consul}"
  security_group_id        = "${var.sg_id_public_services_dc}"
}

# rule granting access from consul to private-services data-center on ports
# 8301...8302 udp
# [server>client] Serf LAN and WAN, UDP
resource "aws_security_group_rule" "sgr_consul_to_private_services_udp" {
  type                     = "ingress"
  description              = "Grants access from consul (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_consul}"
  security_group_id        = "${var.sg_id_private_services_dc}"
}

# rule granting access from consul to content-connector data-center on ports
# 8301...8302 udp
# [server>client] Serf LAN and WAN, UDP
resource "aws_security_group_rule" "sgr_consul_to_content_connector_udp" {
  type                     = "ingress"
  description              = "Grants access from consul (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_consul}"
  security_group_id        = "${var.sg_id_content_connector_dc}"
}

# rule granting access from consul to backoffice data-center on ports
# 8301...8302 udp
# [server>client] Serf LAN and WAN, UDP
resource "aws_security_group_rule" "sgr_consul_to_backoffice_udp" {
  type                     = "ingress"
  description              = "Grants access from consul (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_consul}"
  security_group_id        = "${var.sg_id_backoffice_dc}"
}
