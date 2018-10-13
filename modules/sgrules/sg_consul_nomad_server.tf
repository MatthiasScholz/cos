# INGRESS (Consul ports see: https://www.consul.io/docs/agent/options.html in section 'Ports Used') 
# Server RPC (Default 8300). This is used by servers to handle incoming requests from other agents. TCP only.
# Serf LAN (Default 8301). This is used to handle gossip in the LAN. Required by all agents. TCP and UDP.
# Serf WAN (Default 8302). This is used by servers to gossip over the WAN to other servers. TCP and UDP. 
## As of Consul 0.8, it is recommended to enable connection between servers through port 8302 
## for both TCP and UDP on the LAN interface as well for the WAN Join Flooding feature. See also: Consul 0.8.0 CHANGELOG and GH-3058
# HTTP API (Default 8500). This is used by clients to talk to the HTTP API. TCP only.
# DNS Interface (Default 8600). Used to resolve DNS queries. TCP and UDP.

# rule granting access from nomad server to consul on ports
# 8300...8302 tcp
# [nomad>consul] RCP, Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_nomad_server_to_consul_tcp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (rcp, serf: lan, wan - tcp)"
  from_port                = 8300
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from nomad server to consul on ports
# 8301...8302 udp
# [nomad>consul] Serf LAN and WAN, UDP
resource "aws_security_group_rule" "sgr_nomad_server_to_consul_udp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (serf: lan, wan - udp)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from nomad server to consul on ports
# 8500 tcp
# [nomad>consul] http api
resource "aws_security_group_rule" "sgr_nomad_server_to_consul_http" {
  type                     = "ingress"
  description              = "Grants access from nomad server (http api)"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from nomad server to consul on ports
# 8600 ... tcp
# [nomad>consul] DNS
resource "aws_security_group_rule" "sgr_nomad_server_to_consul_dns_tcp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (dns tcp)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_consul}"
}

# rule granting access from nomad server to consul on ports
# 8600 ... udp
# [nomad>consul] DNS
resource "aws_security_group_rule" "sgr_nomad_server_to_consul_dns_udp" {
  type                     = "ingress"
  description              = "Grants access from nomad server (dns udp)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "udp"
  source_security_group_id = "${var.sg_id_nomad_server}"
  security_group_id        = "${var.sg_id_consul}"
}
