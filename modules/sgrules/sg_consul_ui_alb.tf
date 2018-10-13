# rule granting access ui_alb to consul server on ports
# 8500 http api
resource "aws_security_group_rule" "sgr_ui_alb_to_consul_tcp" {
  type                     = "ingress"
  description              = "Grants access from ui-alb (tcp)"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_ui_alb_nomad}"
  security_group_id        = "${var.sg_id_consul}"
}
