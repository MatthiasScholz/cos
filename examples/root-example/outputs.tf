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
