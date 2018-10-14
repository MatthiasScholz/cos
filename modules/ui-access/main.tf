locals {
  listener_protocol = "${var.ui_alb_use_https_listener?"HTTPS":"HTTP"}"
  listener_port     = "${var.ui_alb_use_https_listener?"443":"80"}"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}
