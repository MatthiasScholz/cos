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

# HTTP listener, used when no https certificate is provided.
resource "aws_alb_listener" "albl_http_consul_ui" {
  count             = "${var.ui_alb_use_https_listener? 0 : 1}"
  load_balancer_arn = "${aws_alb.alb_consul_ui.arn}"
  protocol          = "HTTP"
  port              = "${local.listener_port}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_consul_ui.arn}"
    type             = "forward"
  }
}

# HTTPS listener, used when a https certificate is provided.
resource "aws_alb_listener" "albl_https_consul_ui" {
  count             = "${var.ui_alb_use_https_listener}"
  load_balancer_arn = "${aws_alb.alb_consul_ui.arn}"
  protocol          = "HTTPS"
  port              = "${local.listener_port}"
  certificate_arn   = "${var.ui_alb_https_listener_cert_arn}"
  ssl_policy        = "${local.ssl_policy}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_consul_ui.arn}"
    type             = "forward"
  }
}
