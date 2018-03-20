# the application loadbalancer
resource "aws_alb" "alb_public_services" {
  name            = "alb-public-services"
  internal        = false
  subnets         = ["${aws_subnet.subn_public.*.id}"]
  security_groups = ["${aws_security_group.sg_public_services_alb.id}"]

  tags {
    Name = "${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-ALB-public-services"
  }
}

locals {
  dummy_port = 6000
}

# Listener with empty dummy target group
resource "aws_alb_target_group" "tgr_dummy_public_services" {
  name     = "tgr-dummy-public-services-${var.unique_postfix}""
  port     = "${local.dummy_port}"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-TGR-public-services"
  }
}

# listener for https with one default action to a dummy target group
resource "aws_alb_listener" "albl_dummy-public-services" {
  load_balancer_arn = "${aws_alb.alb_public_services.arn}"
  protocol          = "HTTP"
  port              = "${local.dummy_port}"

  #TODO: add support for https
  #protocol        = "HTTPS"
  #port            = "443"
  #certificate_arn = "${var.dummy_listener_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_dummy_public_services.arn}"
    type             = "forward"
  }
}
