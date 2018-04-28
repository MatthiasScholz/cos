# INGRESS (Consul ports see: https://www.consul.io/docs/agent/options.html in section 'Ports Used') 
# Server RPC (Default 8300). This is used by servers to handle incoming requests from other agents. TCP only.
# Serf LAN (Default 8301). This is used to handle gossip in the LAN. Required by all agents. TCP and UDP.
# Serf WAN (Default 8302). This is used by servers to gossip over the WAN to other servers. TCP and UDP. 
## As of Consul 0.8, it is recommended to enable connection between servers through port 8302 
## for both TCP and UDP on the LAN interface as well for the WAN Join Flooding feature. See also: Consul 0.8.0 CHANGELOG and GH-3058
# HTTP API (Default 8500). This is used by clients to talk to the HTTP API. TCP only.
# DNS Interface (Default 8600). Used to resolve DNS queries. TCP and UDP.

# [client>server] Server RPC
resource "aws_security_group_rule" "sgr_cli_2_srv_rpc_tcp" {
  type                     = "ingress"
  description              = "ig tcp (rpc)"
  from_port                = 8300
  to_port                  = 8300
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.sg_server.id}"
  security_group_id        = "${var.consul_cluster_security_group_id}"
}

# [client>server] Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_cli_2_srv_serf_wan_lan_tcp" {
  type                     = "ingress"
  description              = "ig tcp (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.sg_server.id}"
  security_group_id        = "${var.consul_cluster_security_group_id}"
}

# [client>server] Serf LAN and WAN, UDP
resource "aws_security_group_rule" "sgr_cli_2_srv_serf_wan_lan_udp" {
  type                     = "ingress"
  description              = "ig udp (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.sg_server.id}"
  security_group_id        = "${var.consul_cluster_security_group_id}"
}

# [server>client] Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_srv_2_cli_serf_wan_lan_tcp" {
  type                     = "ingress"
  description              = "ig tcp (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${var.consul_cluster_security_group_id}"
  security_group_id        = "${aws_security_group.sg_server.id}"
}

# [server>client] Serf LAN and WAN, UDP
resource "aws_security_group_rule" "sgr_srv_2_cli_serf_wan_lan_udp" {
  type                     = "ingress"
  description              = "ig udp (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${var.consul_cluster_security_group_id}"
  security_group_id        = "${aws_security_group.sg_server.id}"
}

# [client>server] HTTP API
resource "aws_security_group_rule" "sgr_cli_2_srv_http_api_tcp" {
  type                     = "ingress"
  description              = "ig tcp (http api)"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.sg_server.id}"
  security_group_id        = "${var.consul_cluster_security_group_id}"
}

# [client>server] DNS, TCP
resource "aws_security_group_rule" "sgr_cli_2_srv_dns_tcp" {
  type                     = "ingress"
  description              = "ig tcp (dns)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.sg_server.id}"
  security_group_id        = "${var.consul_cluster_security_group_id}"
}

# [client>server] DNS, UDP
resource "aws_security_group_rule" "sgr_cli_2_srv_dns_udp" {
  type                     = "ingress"
  description              = "ig udp (dns)"
  from_port                = 8600
  to_port                  = 8600
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.sg_server.id}"
  security_group_id        = "${var.consul_cluster_security_group_id}"
}
