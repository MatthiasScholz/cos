## ALB (given by arn) -> ALB-Listener (port 80) -forwards to -> target-group (on port 9999) which is attached to the 
## AutoScalingGroup that maintains the nomad clients having the ingress-controller (i.e. fabio) "public-services".

# Git: Since version 0.3.0 of the nomad terraform module attachments have to be used.

# Define autoscaling attachments to connect the ingress-controller target group with the autoscaling group having the ingress-contoller instances.
resource "aws_autoscaling_attachment" "asga_ingress_controller" {
  count                  = "${var.attach_ingress_alb}"
  autoscaling_group_name = "${module.data_center.asg_name}"
  alb_target_group_arn   = "${aws_alb_target_group.tgr_ingress_controller.arn}"
}

# Targetgroup that points to the ingress-controller (i.e. fabio) port
resource "aws_alb_target_group" "tgr_ingress_controller" {
  count    = "${var.attach_ingress_alb}"
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

# listener for http with one default action to a fabio target group
resource "aws_alb_listener" "albl_http_ingress_controller" {
  count             = "${var.attach_ingress_alb}"
  load_balancer_arn = "${var.alb_ingress_arn}"

  protocol = "HTTP"
  port     = "80"

  #TODO: add support for https
  #protocol        = "HTTPS"
  #port            = "443"
  #certificate_arn = "${var.dummy_listener_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_ingress_controller.arn}"
    type             = "forward"
  }
}
