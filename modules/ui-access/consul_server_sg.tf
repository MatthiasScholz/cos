data "aws_security_group" "sg_consul_server" {
  id = "${var.consul_server_sg_id}"
}

# ingress access from ui alb over port 8500 to consul servers
resource "aws_security_group_rule" "sgr_alb_consul_ig8500" {
  type        = "ingress"
  description = "http access from UI ALB"
  from_port   = 8500
  to_port     = 8500
  protocol    = "tcp"

  source_security_group_id = "${aws_security_group.sg_ui_alb.id}"
  security_group_id        = "${data.aws_security_group.sg_consul_server.id}"
}
