# Git: Since version 0.3.0 of the nomad terraform module attachments have to be used.

# Define autoscaling attachments to connect the target groups with the autoscaling group
resource "aws_autoscaling_attachment" "asg_attachment_fabio" {
  autoscaling_group_name = "${module.nomad_clients.asg_name}"
  alb_target_group_arn   = "${aws_alb_target_group.targetgroup_fabio.arn}"
}

# Listener with fabio target group
resource "aws_alb_target_group" "targetgroup_fabio" {
  name = "tgr-fabio"

  # TODO: UNDERSTAND PORT NUMBER and TARGET GROUPS
  port     = 9999
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
    Name = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-TGR-fabio"
  }
}

# listener for http with one default action to a fabio target group
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${var.alb_public_services_arn}"

  protocol = "HTTP"
  port     = "80"

  default_action {
    target_group_arn = "${aws_alb_target_group.targetgroup_fabio.arn}"
    type             = "forward"
  }
}
