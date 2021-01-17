locals {
  dummy_port = 6000
}

# the application loadbalancer
resource "aws_alb" "alb_public_services" {
  name            = "${var.stack_name}-ingress${var.unique_postfix}"
  internal        = false
  subnets         = aws_subnet.subn_public.*.id
  security_groups = [aws_security_group.sg_public_services_alb.id]

  tags = {
    Name     = "${var.stack_name}-ingress${var.unique_postfix}"
    internal = false
  }
}

# Listener with empty dummy target group
resource "aws_alb_target_group" "tgr_dummy_public_services" {
  name     = "${var.stack_name}-igress-dummy${var.unique_postfix}"
  port     = local.dummy_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_main.id

  tags = {
    Name = "${var.stack_name}-igress-dummy${var.unique_postfix}"
  }
}

# listener for https with one default action to a dummy target group
resource "aws_alb_listener" "alb_ingress_https" {
  load_balancer_arn = aws_alb.alb_public_services.arn

  # HACK: currently protocol is https although this is the https listener.
  protocol = "HTTP"
  port     = "443"

  #TODO: add support for https
  #protocol        = "HTTPS"
  #certificate_arn = "${var.dummy_listener_certificate_arn}"

  default_action {
    target_group_arn = aws_alb_target_group.tgr_dummy_public_services.arn
    type             = "forward"
  }
}

# listener for http with one default action to a dummy target group
resource "aws_alb_listener" "alb_ingress_http" {
  load_balancer_arn = aws_alb.alb_public_services.arn
  protocol          = "HTTP"
  port              = "80"

  default_action {
    target_group_arn = aws_alb_target_group.tgr_dummy_public_services.arn
    type             = "forward"
  }
}

