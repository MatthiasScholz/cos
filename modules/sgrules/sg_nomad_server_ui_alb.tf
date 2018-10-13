# rule granting access ui_alb to nomad server on ports
# 4646 tcp, http api
resource "aws_security_group_rule" "sgr_ui_alb_to_nomad_server_tcp" {
  type                     = "ingress"
  description              = "Grants access from ui-alb (tcp)"
  from_port                = 4646
  to_port                  = 4646
  protocol                 = "tcp"
  source_security_group_id = "${var.sg_id_ui_alb_nomad}"
  security_group_id        = "${var.sg_id_nomad_server}"
}
