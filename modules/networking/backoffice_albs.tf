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
  subnets         = ["${aws_subnet.subn_public.*.id}"]
  security_groups = ["${aws_security_group.sg_backoffice_nomad_alb.id}"]

  tags {
    Name = "${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-ALB-backoffice-nomad"
  }
}

# Listener with empty dummy target group
resource "aws_alb_target_group" "tgr_dummy_backoffice_nomad" {
  name     = "tgr-dummy-bo-nomad-${var.unique_postfix}"
  port     = "${local.dummy_port_bo}"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-TGR-backoffice-nomad"
  }
}

# Listener for https with one default action to a dummy target group
resource "aws_alb_listener" "alb_dummy-backoffice-nomad" {
  load_balancer_arn = "${aws_alb.alb_backoffice_nomad.arn}"
  protocol          = "HTTP"
  port              = "${local.dummy_port_bo}"

  #TODO: add support for https
  #protocol        = "HTTPS"
  #port            = "443"
  #certificate_arn = "${var.dummy_listener_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_dummy_backoffice_nomad.arn}"
    type             = "forward"
  }
}


############################################
# The application loadbalancer for Consul UI
############################################
resource "aws_alb" "alb_backoffice_consul" {
  name            = "alb-backoffice-consul"
  internal        = false
  subnets         = ["${aws_subnet.subn_public.*.id}"]
  security_groups = ["${aws_security_group.sg_backoffice_consul_alb.id}"]

  tags {
    Name = "${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-ALB-backoffice-consul"
  }
}


# Listener with empty dummy target group
resource "aws_alb_target_group" "tgr_dummy_backoffice_consul" {
  name     = "tgr-dummy-bo-consul-${var.unique_postfix}"
  port     = "${local.dummy_port_bo}"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-TGR-backoffice-consul"
  }
}

# Listener for https with one default action to a dummy target group
resource "aws_alb_listener" "alb_dummy-backoffice-consul" {
  load_balancer_arn = "${aws_alb.alb_backoffice_consul.arn}"
  protocol          = "HTTP"
  port              = "${local.dummy_port_bo}"

  #TODO: add support for https
  #protocol        = "HTTPS"
  #port            = "443"
  #certificate_arn = "${var.dummy_listener_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_dummy_backoffice_consul.arn}"
    type             = "forward"
  }
}


###########################################
# The application loadbalancer for Fabio UI
###########################################
resource "aws_alb" "alb_backoffice_fabio" {
  name            = "alb-backoffice-fabio"
  internal        = false
  subnets         = ["${aws_subnet.subn_public.*.id}"]
  security_groups = ["${aws_security_group.sg_backoffice_fabio_alb.id}"]

  tags {
    Name = "${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-ALB-backoffice-fabio"
  }
}

# Listener with empty dummy target group
resource "aws_alb_target_group" "tgr_dummy_backoffice_fabio" {
  name     = "tgr-dummy-bo-fabio-${var.unique_postfix}"
  port     = "${local.dummy_port_bo}"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-TGR-backoffice-fabio"
  }
}

# Listener for https with one default action to a dummy target group
resource "aws_alb_listener" "alb_dummy-backoffice-fabio" {
  load_balancer_arn = "${aws_alb.alb_backoffice_fabio.arn}"
  protocol          = "HTTP"
  port              = "${local.dummy_port_bo}"

  #TODO: add support for https
  #protocol        = "HTTPS"
  #port            = "443"
  #certificate_arn = "${var.dummy_listener_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tgr_dummy_backoffice_fabio.arn}"
    type             = "forward"
  }
}
