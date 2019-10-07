locals {
  protocols = ["tcp","udp"]
}

# rule granting access from consul to nomad server on ports
# 8300...8302 tcp and udp
# [consul>nomad] RCP, Serf LAN and WAN, TCP + UDP
resource "aws_security_group_rule" "sgr_consul_to_nomad_server" {
  count = length(local.protocols)

  type                     = "ingress"
  description              = "Grants access from consul server (rcp, serf: lan, wan - ${element(local.protocols,count.index)})"
  from_port                = 8300
  to_port                  = 8302
  protocol                 = element(local.protocols,count.index)
  source_security_group_id = module.consul.security_group_id_consul_servers
  security_group_id        = module.nomad.security_group_id_nomad_servers
}