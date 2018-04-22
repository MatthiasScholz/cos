# obtain consul sg in order to add rules needed 
data "aws_security_group" "consul_sg" {
  id = "${module.consul_servers.security_group_id}"
}

# Consul ports see: https://www.consul.io/docs/agent/options.html in section 'Ports Used' 
# Server RPC (Default 8300). This is used by servers to handle incoming requests from other agents. TCP only.
# Serf LAN (Default 8301). This is used to handle gossip in the LAN. Required by all agents. TCP and UDP.
# Serf WAN (Default 8302). This is used by servers to gossip over the WAN to other servers. TCP and UDP. 
## As of Consul 0.8, it is recommended to enable connection between servers through port 8302 
## for both TCP and UDP on the LAN interface as well for the WAN Join Flooding feature. See also: Consul 0.8.0 CHANGELOG and GH-3058
# HTTP API (Default 8500). This is used by clients to talk to the HTTP API. TCP only.
# DNS Interface (Default 8600). Used to resolve DNS queries. TCP and UDP.

# [server>server] Serf LAN and WAN, TCP
resource "aws_security_group_rule" "sgr_srv_2_srv_serf_wan_lan_tcp" {
  type                     = "ingress"
  description              = "ig tcp (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "tcp"
  source_security_group_id = "${data.aws_security_group.consul_sg.id}"
  security_group_id        = "${data.aws_security_group.consul_sg.id}"
}

# [server>server] Serf LAN and WAN, UDP
resource "aws_security_group_rule" "sgr_srv_2_srv_serf_wan_lan_udp" {
  type                     = "ingress"
  description              = "ig udp (serf: wan/lan)"
  from_port                = 8301
  to_port                  = 8302
  protocol                 = "udp"
  source_security_group_id = "${data.aws_security_group.consul_sg.id}"
  security_group_id        = "${data.aws_security_group.consul_sg.id}"
}

# [server>server] Server RPC, TCP
resource "aws_security_group_rule" "sgr_srv_2_srv_rpc_tcp" {
  type                     = "ingress"
  description              = "ig tcp server RPC"
  from_port                = 8300
  to_port                  = 8300
  protocol                 = "tcp"
  source_security_group_id = "${data.aws_security_group.consul_sg.id}"
  security_group_id        = "${data.aws_security_group.consul_sg.id}"
}
