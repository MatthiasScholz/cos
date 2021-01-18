resource "aws_alb" "alb_backoffice" {
  name            = "${var.stack_name}-backoffice${var.unique_postfix}"
  internal        = false
  subnets         = aws_subnet.subn_public.*.id
  security_groups = [aws_security_group.sg_backoffice_alb.id]

  tags = {
    Name     = "${var.stack_name}-backoffice${var.unique_postfix}"
    internal = false
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_backoffice" {
  autoscaling_group_name = var.asg_name_backoffice
  alb_target_group_arn   = aws_alb_target_group.tgr_backoffice.arn
}

resource "aws_alb_target_group" "tgr_backoffice" {
  name     = "${var.stack_name}-backoffice-${var.unique_postfix}-${substr(uuid(),0 ,4)}"
  port     = 9998
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_main.id

  health_check {
    path = "/health"
    port = 9998
    timeout = 2
    interval = 10
    matcher = "200"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [name]
  }

  tags = {
    Name = "${var.stack_name}-backoffice-${var.unique_postfix}"
  }
}

resource "aws_alb_listener" "alb_backoffice_http" {
  load_balancer_arn = aws_alb.alb_backoffice.arn

  protocol = "HTTP"
  port     = "80"

  default_action {
    target_group_arn = aws_alb_target_group.tgr_backoffice.arn
    type             = "forward"
  }
}
