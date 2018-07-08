locals {
  dummy_port = 6000
}

# the application loadbalancer
resource "aws_alb" "alb_public_services" {
  name            = "${var.stack_name}-ingress${var.unique_postfix}"
  internal        = false
  subnets         = ["${aws_subnet.subn_public.*.id}"]
  security_groups = ["${aws_security_group.sg_public_services_alb.id}"]

  tags {
    Name     = "${var.stack_name}-ingress${var.unique_postfix}"
    internal = false
  }
}

# listener for http with one default action to a fabio target group
# FIXME: Why is it named: "albl..." ?
resource "aws_alb_listener" "albl_http_ingress_controller" {
  count             = "${var.attach_ingress_alb}"
  load_balancer_arn = "${aws_alb.alb_public_services.arn}"

  protocol = "HTTP"
  port     = "80"

  default_action {
    # FIXME: What to do here??? - this is defined in module/nomad-datacenter/alb_ingress_attachment.tf
    target_group_arn = "${aws_alb_target_group.tgr_ingress_controller.arn}"
    type             = "forward"
  }
}

# NOT YET WORKING resource "aws_alb_listener" "albl_https_ingress_controller" {
# NOT YET WORKING   count             = "${var.attach_ingress_alb}"
# NOT YET WORKING   load_balancer_arn = "${aws_alb.alb_public_services.arn}"
# NOT YET WORKING 
# NOT YET WORKING   protocol = "HTTPS"
# NOT YET WORKING   port     = "443"
# NOT YET WORKING   certificate_arn = "${var.dummy_listener_certificate_arn}"
# NOT YET WORKING 
# NOT YET WORKING   default_action {
# NOT YET WORKING     target_group_arn = "${aws_alb_target_group.tgr_ingress_controller.arn}"
# NOT YET WORKING     type             = "forward"
# NOT YET WORKING   }
# NOT YET WORKING }
