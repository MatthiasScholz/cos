# Git: Since version 0.3.0 of the nomad terraform module attachments have to be used.

resource "aws_autoscaling_attachment" "asg_attachment_fabio_ui" {
  autoscaling_group_name = "${module.nomad_clients.asg_name}"
  alb_target_group_arn   = "${aws_alb_target_group.targetgroup_fabio_ui.arn}"
}

resource "aws_autoscaling_attachment" "asg_attachment_consul_ui" {
  autoscaling_group_name = "${module.consul_servers.asg_name}"
  alb_target_group_arn   = "${aws_alb_target_group.targetgroup_consul_ui.arn}"
}

resource "aws_autoscaling_attachment" "asg_attachment_nomad_ui" {
  autoscaling_group_name = "${module.nomad_servers.asg_name}"
  alb_target_group_arn   = "${aws_alb_target_group.targetgroup_nomad_ui.arn}"
}


##########
# Fabio UI
##########
resource "aws_alb_target_group" "targetgroup_fabio_ui" {
  name = "tgr-fabio-ui"

  # TODO: UNDERSTAND PORT NUMBER and TARGET GROUPS
  port     = 9998
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    interval            = 15
    path                = "/health"
    port                = 9998
    protocol            = "HTTP"
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags {
    Name = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-TGR-fabio-ui"
  }
}

# listener for http with one default action to a fabio target group
resource "aws_alb_listener" "listener_http_ui_fabio" {
  load_balancer_arn = "${var.alb_backoffice_fabio_arn}"

  protocol = "HTTP"
  port     = "80"

  default_action {
    target_group_arn = "${aws_alb_target_group.targetgroup_fabio_ui.arn}"
    type             = "forward"
  }
}


###########
# Consul UI
###########
resource "aws_alb_target_group" "targetgroup_consul_ui" {
  name = "tgr-consul-ui"

  # TODO: UNDERSTAND PORT NUMBER and TARGET GROUPS
  port     = 8500
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    interval            = 15
    path                = "/v1/status/leader"
    port                = 8500
    protocol            = "HTTP"
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags {
    Name = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-TGR-consul-ui"
  }
}

# listener for http with one default action to a fabio target group
resource "aws_alb_listener" "listener_http_ui_consul" {
  load_balancer_arn = "${var.alb_backoffice_consul_arn}"

  protocol = "HTTP"
  port     = "80"

  default_action {
    target_group_arn = "${aws_alb_target_group.targetgroup_consul_ui.arn}"
    type             = "forward"
  }
}

##########
# Nomad UI
##########
resource "aws_alb_target_group" "targetgroup_nomad_ui" {
  name = "tgr-nomad-ui"

  # TODO: UNDERSTAND PORT NUMBER and TARGET GROUPS
  port     = 4646
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    interval            = 15
    path                = "/ui/jobs"
    port                = 4646
    protocol            = "HTTP"
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags {
    Name = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-TGR-nomad-ui"
  }
}

# listener for http with one default action to a nomad target group
resource "aws_alb_listener" "listener_http_ui_nomad" {
  load_balancer_arn = "${var.alb_backoffice_nomad_arn}"

  protocol = "HTTP"
  port     = "80"

  default_action {
    target_group_arn = "${aws_alb_target_group.targetgroup_nomad_ui.arn}"
    type             = "forward"
  }
}
