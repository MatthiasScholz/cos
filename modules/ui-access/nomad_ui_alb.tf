#########
# General
# abreviation: bo -> backoffice
#########
locals {
  dummy_port_bo = 6000
}

###########################################
# The application loadbalancer for Nomad UI
###########################################
resource "aws_alb" "alb_backoffice_nomad" {
  name            = "alb-backoffice-nomad"
  internal        = false
  subnets         = ["${var.subnet_ids}"]
  security_groups = ["${aws_security_group.sg_backoffice_nomad_alb.id}"]

  tags {
    Name = "${var.stack_name}-${var.aws_region}-ALB-backoffice-nomad"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_nomad_ui" {
  autoscaling_group_name = "${var.nomad_server_asg_name}"
  alb_target_group_arn   = "${aws_alb_target_group.targetgroup_nomad_ui.arn}"
}

##########
# Nomad UI
##########
resource "aws_alb_target_group" "targetgroup_nomad_ui" {
  name = "tgr-nomad-ui"

  # TODO: UNDERSTAND PORT NUMBER and TARGET GROUPS
  port     = 4646
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    interval            = 15
    path                = "/ui/jobs"
    port                = 4646
    protocol            = "HTTP"
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags {
    Name = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-TGR-nomad-ui"
  }
}

# listener for http with one default action to a nomad target group
resource "aws_alb_listener" "listener_http_ui_nomad" {
  load_balancer_arn = "${aws_alb.alb_backoffice_nomad.arn}"

  #TODO: add support for https
  #protocol        = "HTTPS"
  #port            = "443"
  #certificate_arn = "${var.dummy_listener_certificate_arn}"

  protocol = "HTTP"
  port     = "80"
  default_action {
    target_group_arn = "${aws_alb_target_group.targetgroup_nomad_ui.arn}"
    type             = "forward"
  }
}

# Listener with empty dummy target group
resource "aws_alb_target_group" "tgr_dummy_backoffice_nomad" {
  name     = "tgr-dummy-bo-nomad-${var.unique_postfix}"
  port     = "${local.dummy_port_bo}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  tags {
    Name = "${var.stack_name}-${var.aws_region}-TGR-backoffice-nomad"
  }
}

#############################################
## The application loadbalancer for Consul UI
#############################################
#resource "aws_alb" "alb_backoffice_consul" {
#  name            = "alb-backoffice-consul"
#  internal        = false
#  subnets         = ["${aws_subnet.subn_public.*.id}"]
#  security_groups = ["${aws_security_group.sg_backoffice_consul_alb.id}"]
#
#  tags {
#    Name = "${var.stack_name}-${var.aws_region}${element(var.az_postfixes,count.index)}-ALB-backoffice-consul"
#  }
#}
#
## Listener with empty dummy target group
#resource "aws_alb_target_group" "tgr_dummy_backoffice_consul" {
#  name     = "tgr-dummy-bo-consul-${var.unique_postfix}"
#  port     = "${local.dummy_port_bo}"
#  protocol = "HTTP"
#  vpc_id   = "${aws_vpc.vpc_main.id}"
#
#  tags {
#    Name = "${var.stack_name}-${var.aws_region}${element(var.az_postfixes,count.index)}-TGR-backoffice-consul"
#  }
#}
#
## Listener for https with one default action to a dummy target group
#resource "aws_alb_listener" "alb_dummy-backoffice-consul" {
#  load_balancer_arn = "${aws_alb.alb_backoffice_consul.arn}"
#  protocol          = "HTTP"
#  port              = "${local.dummy_port_bo}"
#
#  #TODO: add support for https
#  #protocol        = "HTTPS"
#  #port            = "443"
#  #certificate_arn = "${var.dummy_listener_certificate_arn}"
#
#  default_action {
#    target_group_arn = "${aws_alb_target_group.tgr_dummy_backoffice_consul.arn}"
#    type             = "forward"
#  }
#}
#
############################################
## The application loadbalancer for Fabio UI
############################################
#resource "aws_alb" "alb_backoffice_fabio" {
#  name            = "alb-backoffice-fabio"
#  internal        = false
#  subnets         = ["${aws_subnet.subn_public.*.id}"]
#  security_groups = ["${aws_security_group.sg_backoffice_fabio_alb.id}"]
#
#  tags {
#    Name = "${var.stack_name}-${var.aws_region}${element(var.az_postfixes,count.index)}-ALB-backoffice-fabio"
#  }
#}
#
## Listener with empty dummy target group
#resource "aws_alb_target_group" "tgr_dummy_backoffice_fabio" {
#  name     = "tgr-dummy-bo-fabio-${var.unique_postfix}"
#  port     = "${local.dummy_port_bo}"
#  protocol = "HTTP"
#  vpc_id   = "${aws_vpc.vpc_main.id}"
#
#  tags {
#    Name = "${var.stack_name}-${var.aws_region}${element(var.az_postfixes,count.index)}-TGR-backoffice-fabio"
#  }
#}
#
## Listener for https with one default action to a dummy target group
#resource "aws_alb_listener" "alb_dummy-backoffice-fabio" {
#  load_balancer_arn = "${aws_alb.alb_backoffice_fabio.arn}"
#  protocol          = "HTTP"
#  port              = "${local.dummy_port_bo}"
#
#  #TODO: add support for https
#  #protocol        = "HTTPS"
#  #port            = "443"
#  #certificate_arn = "${var.dummy_listener_certificate_arn}"
#
#  default_action {
#    target_group_arn = "${aws_alb_target_group.tgr_dummy_backoffice_fabio.arn}"
#    type             = "forward"
#  }
#}
#

