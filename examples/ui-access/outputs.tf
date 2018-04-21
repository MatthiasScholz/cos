output "nomad_ui_alb_dns" {
  value = "${module.ui-access.nomad_ui_alb_dns}"
}

output "curl_nomad_ui" {
  value = "curl http://${module.ui-access.nomad_ui_alb_dns}/ui/jobs"
}

output "consul_ui_alb_dns" {
  value = "${module.ui-access.consul_ui_alb_dns}"
}

output "curl_consul_ui" {
  value = "curl http://${module.ui-access.consul_ui_alb_dns}/v1/status/leader"
}

output "fabio_ui_alb_dns" {
  value = "${module.ui-access.fabio_ui_alb_dns}"
}

output "curl_fabio_ui" {
  value = "curl http://${module.ui-access.fabio_ui_alb_dns}/health"
}
