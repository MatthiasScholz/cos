# the application loadbalancer
resource "aws_alb" "alb_backoffice" {
  name            = "${var.stack_name}-backoffice${var.unique_postfix}"
  internal        = false
  subnets         = ["${aws_subnet.subn_public.*.id}"]
  security_groups = ["${aws_security_group.sg_backoffice_alb.id}"]

  tags {
    Name     = "${var.stack_name}-backoffice${var.unique_postfix}"
    internal = false
  }
}

# Listener with empty dummy target group
resource "aws_alb_target_group" "tgr_dummy_backoffice" {
  name     = "${var.stack_name}-dummy${var.unique_postfix}"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "${var.stack_name}-dummy${var.unique_postfix}"
  }
}

# listener for https with one default action to a dummy target group
resource "aws_alb_listener" "alb_backoffice_https" {
  load_balancer_arn = "${aws_alb.alb_backoffice.arn}"

  # HACK: currently protocol is https although this is the https listener.
  protocol = "HTTP"
  port     = "443"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_dummy_backoffice.arn}"
    type             = "forward"
  }
}
