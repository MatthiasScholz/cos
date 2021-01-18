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

resource "aws_autoscaling_attachment" "asg_attachment_public_services" {
  autoscaling_group_name = var.asg_name_public_services
  alb_target_group_arn   = aws_alb_target_group.tgr_public_services
}

resource "aws_alb_target_group" "tgr_public_services" {
  name     = "${var.stack_name}-ingress-${var.unique_postfix}"
  port     = 9998
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_main.id

  health_check {
    path = "/health"
    port = 9998
    timeout = 2
    interval = 10
    matcher = "200-299"
  }

  tags = {
    Name = "${var.stack_name}-ingress-${var.unique_postfix}"
  }
}

resource "aws_alb_listener" "alb_ingress_https" {
  load_balancer_arn = aws_alb.alb_public_services.arn

  protocol = "HTTP"
  port     = "443"

  #TODO: add support for https
  #protocol        = "HTTPS"
  #certificate_arn = "${var.dummy_listener_certificate_arn}"

  default_action {
    target_group_arn = aws_alb_target_group.tgr_public_services.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "alb_ingress_http" {
  load_balancer_arn = aws_alb.alb_public_services.arn
  protocol          = "HTTP"
  port              = "80"

  default_action {
    target_group_arn = aws_alb_target_group.tgr_public_services.arn
    type             = "forward"
  }
}

