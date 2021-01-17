locals {
  # The rule_map contains the spec for the security group rules that should be applied.
  # An entry is of the form "<description>" = ["<protocol>",<from_port>,<to_port>]
  rule_map = {
    "Grants access from nomad (rcp, serf: lan, wan - tcp)" =  ["tcp",8300,8302],
    "Grants access from nomad (rcp, serf: lan, wan - udp)" =  ["udp",8301,8302],
    "Grants access from nomad (http)" =  ["tcp",8500,8500],
    "Grants access from nomad (dns tcp)" =  ["tcp",8600,8600],
    "Grants access from nomad (dns udp)" =  ["udp",8600,8600],
  }
}

# rule granting access from nomad to consul on ports defined in rule_map
# [nomad>consul]
resource "aws_security_group_rule" "sgr_nomad_to_consul" {

  for_each = local.rule_map

  type                     = "ingress"
  description              = each.key
  protocol                 = element(each.value,0)
  from_port                = element(each.value,1)
  to_port                  = element(each.value,2)
  source_security_group_id = module.nomad.security_group_id_nomad_servers
  security_group_id        = module.consul.security_group_id_consul_servers
}