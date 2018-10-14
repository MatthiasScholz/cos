## ALB -> ALB-Listener (port 80) -forwards to -> target-group (on port 4646) which is attached to the 
## AutoScalingGroup that maintains the fabio-servers.
resource "aws_alb" "alb_fabio_ui" {
  name            = "${var.stack_name}-fabio-ui${var.unique_postfix}"
  internal        = false
  subnets         = ["${var.subnet_ids}"]
  security_groups = ["${aws_security_group.sg_ui_alb.id}"]

  tags {
    Name = "${var.stack_name}-fabio-ui${var.unique_postfix}"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_fabio_ui" {
  autoscaling_group_name = "${var.fabio_server_asg_name}"
  alb_target_group_arn   = "${aws_alb_target_group.tgr_fabio_ui.arn}"
}

resource "aws_alb_target_group" "tgr_fabio_ui" {
  name_prefix = "fabio"
  port        = "${var.fabio_ui_port}"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"

  health_check {
    interval            = 15
    path                = "/health"
    port                = "${var.fabio_ui_port}"
    protocol            = "HTTP"
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags {
    Name = "${var.stack_name}-fabio-ui${var.unique_postfix}"
  }
}

# HTTP listener, used when no https certificate is provided.
resource "aws_alb_listener" "albl_http_fabio_ui" {
  count             = "${var.ui_alb_use_https_listener? 0 : 1}"
  load_balancer_arn = "${aws_alb.alb_fabio_ui.arn}"
  protocol          = "HTTP"
  port              = "${local.listener_port}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_fabio_ui.arn}"
    type             = "forward"
  }
}

# HTTPS listener, used when a https certificate is provided.
resource "aws_alb_listener" "albl_https_fabio_ui" {
  count             = "${var.ui_alb_use_https_listener}"
  load_balancer_arn = "${aws_alb.alb_fabio_ui.arn}"
  protocol          = "HTTPS"
  port              = "${local.listener_port}"
  certificate_arn   = "${var.ui_alb_https_listener_cert_arn}"
  ssl_policy        = "${local.ssl_policy}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_fabio_ui.arn}"
    type             = "forward"
  }
}
