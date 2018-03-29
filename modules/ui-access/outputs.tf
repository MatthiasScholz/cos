output "nomad_ui_alb_dns" {
  value = "${aws_alb.alb_nomad_ui.dns_name}"
}

output "consul_ui_alb_dns" {
  value = "${aws_alb.alb_consul_ui.dns_name}"
}

output "fabio_ui_alb_dns" {
  value = "${aws_alb.alb_fabio_ui.dns_name}"
}
