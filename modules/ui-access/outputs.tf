output "nomad_ui_alb_dns_name" {
  value = "${aws_alb.alb_nomad_ui.dns_name}"
}

output "consul_ui_alb_dns_name" {
  value = "${aws_alb.alb_consul_ui.dns_name}"
}

output "fabio_ui_alb_dns_name" {
  value = "${aws_alb.alb_fabio_ui.dns_name}"
}

output "nomad_ui_alb_zone_id" {
  value = "${aws_alb.alb_nomad_ui.zone_id}"
}

output "consul_ui_alb_zone_id" {
  value = "${aws_alb.alb_consul_ui.zone_id}"
}

output "fabio_ui_alb_zone_id" {
  value = "${aws_alb.alb_fabio_ui.zone_id}"
}

output "nomad_ui_alb_sg_id" {
  value = "${aws_security_group.sg_ui_alb.id}"
}

output "consul_ui_alb_sg_id" {
  value = "${aws_security_group.sg_ui_alb.id}"
}

output "fabio_ui_alb_sg_id" {
  value = "${aws_security_group.sg_ui_alb.id}"
}
