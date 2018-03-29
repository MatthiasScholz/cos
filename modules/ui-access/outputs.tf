output "nomad_ui_alb_dns" {
  value = "${aws_alb.alb_nomad_ui.dns_name}"
}
