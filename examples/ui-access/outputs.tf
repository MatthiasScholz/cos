output "nomad_ui_alb_dns" {
  value = "${module.ui-access.nomad_ui_alb_dns}"
}

output "curl_nomad_ui" {
  value = "curl http://${module.ui-access.nomad_ui_alb_dns}/ui/jobs"
}
