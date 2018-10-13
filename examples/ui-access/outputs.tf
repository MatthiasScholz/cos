output "nomad_ui_alb_dns" {
  value = "${module.ui-access.nomad_ui_alb_dns_name}"
}

output "curl_nomad_ui" {
  value = "curl http://${module.ui-access.nomad_ui_alb_dns_name}/ui/jobs"
}

output "consul_ui_alb_dns" {
  value = "${module.ui-access.consul_ui_alb_dns_name}"
}

output "curl_consul_ui" {
  value = "curl http://${module.ui-access.consul_ui_alb_dns_name}/v1/status/leader"
}

output "fabio_ui_alb_dns" {
  value = "${module.ui-access.fabio_ui_alb_dns_name}"
}

output "curl_fabio_ui" {
  value = "curl http://${module.ui-access.fabio_ui_alb_dns_name}/health"
}
