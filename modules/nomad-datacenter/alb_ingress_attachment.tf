## ALB (given by arn) -> ALB-Listener (var.ingress_controller_port) -forwards to -> target-group (on port 9999) which is attached to the 
## AutoScalingGroup that maintains the nomad clients having the ingress-controller (i.e. fabio) "public-services".

# Git: Since version 0.3.0 of the nomad terraform module attachments have to be used.

# Define autoscaling attachments to connect the ingress-controller target group with the autoscaling group having the ingress-contoller instances.
resource "aws_autoscaling_attachment" "asga_ingress_controller" {
  count                  = "${var.attach_ingress_alb_listener}"
  autoscaling_group_name = "${module.data_center.asg_name}"
  alb_target_group_arn   = "${aws_alb_target_group.tgr_ingress_controller.arn}"
}

# Targetgroup that points to the ingress-controller (i.e. fabio) port
resource "aws_alb_target_group" "tgr_ingress_controller" {
  count    = "${var.attach_ingress_alb_listener}"
  name     = "${var.datacenter_name}-inctl${var.unique_postfix}"
  port     = "${var.ingress_controller_port}"
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
    Name = "${var.stack_name}-${var.datacenter_name}-ingress-controller${var.unique_postfix}"
  }
}

# listener rule for HTTPS
resource "aws_alb_listener_rule" "alr_ingress_https" {
  count        = "${var.attach_ingress_alb_listener}"
  listener_arn = "${var.alb_ingress_https_listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.tgr_ingress_controller.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}
