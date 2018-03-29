output "aws_region" {
  value = "${var.aws_region}"
}

output "nomad_servers_cluster_tag_key" {
  value = "${module.nomad-infra.nomad_servers_cluster_tag_key}"
}

output "nomad_servers_cluster_tag_value" {
  value = "${module.nomad-infra.nomad_servers_cluster_tag_value}"
}

output "num_nomad_servers" {
  value = "${module.nomad-infra.num_nomad_servers}"
}

output "nomad_clients_cluster_tag_value" {
  value = "${module.nomad-infra.nomad_clients_cluster_tag_value}"
}

output "nomad_ui_alb_dns" {
  value = "${module.nomad-infra.nomad_ui_alb_dns}"
}

output "curl_nomad_ui" {
  value = "curl http://${module.nomad-infra.nomad_ui_alb_dns}/ui/jobs"
}

output "consul_ui_alb_dns" {
  value = "${module.nomad-infra.consul_ui_alb_dns}"
}

output "curl_consul_ui" {
  value = "curl http://${module.nomad-infra.consul_ui_alb_dns}/v1/status/leader"
}

output "fabio_ui_alb_dns" {
  value = "${module.nomad-infra.fabio_ui_alb_dns}"
}

output "curl_fabio_ui" {
  value = "curl http://${module.nomad-infra.fabio_ui_alb_dns}/health"
}
