# the application loadbalancer
resource "aws_alb" "alb_public_services" {
  name            = "alb-public-services"
  internal        = false
  subnets         = ["${aws_subnet.subn_public.*.id}"]
  security_groups = ["${aws_security_group.sg_alb.id}"]

  tags {
    Name = "ALB-public-services"
  }
}

# Listener with empty dummy target group
resource "aws_alb_target_group" "dummy_targetgroup_alb_public_services" {
  name     = "alb-dummy-public-services"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "TGR-public-services"
  }
}

# listener for https with one default action to a dummy target group
resource "aws_alb_listener" "alb_authentication_https_listener" {
  load_balancer_arn = "${aws_alb.alb_public_services.arn}"
  protocol          = "HTTP"
  port              = "80"

  #protocol        = "HTTPS"
  #port            = "443"
  #certificate_arn = "${var.dummy_listener_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.dummy_targetgroup_alb_public_services.arn}"
    type             = "forward"
  }
}
