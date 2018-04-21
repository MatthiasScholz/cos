## ALB -> ALB-Listener (port 80) -forwards to -> target-group (on port 8500) which is attached to the 
## AutoScalingGroup that maintains the consul-servers.
resource "aws_alb" "alb_consul_ui" {
  name            = "${var.stack_name}-consul-ui${var.unique_postfix}"
  internal        = false
  subnets         = ["${var.subnet_ids}"]
  security_groups = ["${aws_security_group.sg_ui_alb.id}"]

  tags {
    Name = "${var.stack_name}-consul-ui${var.unique_postfix}"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_consul_ui" {
  autoscaling_group_name = "${var.consul_server_asg_name}"
  alb_target_group_arn   = "${aws_alb_target_group.tgr_consul_ui.arn}"
}

resource "aws_alb_target_group" "tgr_consul_ui" {
  name_prefix = "consul"
  port        = "${var.consul_ui_port}"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"

  health_check {
    interval            = 15
    path                = "/v1/status/leader"
    port                = "${var.consul_ui_port}"
    protocol            = "HTTP"
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags {
    Name = "${var.stack_name}-consul-ui${var.unique_postfix}"
  }
}

resource "aws_alb_listener" "albl_http_consul_ui" {
  load_balancer_arn = "${aws_alb.alb_consul_ui.arn}"

  #TODO: add support for https
  #protocol        = "HTTPS"
  #port            = "443"
  #certificate_arn = "${var.dummy_listener_certificate_arn}"

  protocol = "HTTP"
  port     = "80"
  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_consul_ui.arn}"
    type             = "forward"
  }
}
