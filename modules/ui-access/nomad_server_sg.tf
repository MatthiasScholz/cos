data "aws_security_group" "sg_nomad_server" {
  id = "${var.nomad_server_sg_id}"
}

# ingress access from ui alb over port 4646 to nomad servers
resource "aws_security_group_rule" "sgr_alb_ig4646" {
  type        = "ingress"
  description = "http access from UI ALB"
  from_port   = 4646
  to_port     = 4646
  protocol    = "tcp"

  source_security_group_id = "${aws_security_group.sg_ui_alb.id}"
  security_group_id        = "${data.aws_security_group.sg_nomad_server.id}"
}
