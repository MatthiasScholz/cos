output "aws_region" {
  value = "${var.aws_region}"
}

output "nomad_servers_cluster_tag_key" {
  value = "${module.nomad.nomad_servers_cluster_tag_key}"
}

output "nomad_servers_cluster_tag_value" {
  value = "${module.nomad.nomad_servers_cluster_tag_value}"
}

output "num_nomad_servers" {
  value = "${module.nomad.num_nomad_servers}"
}

output "nomad_clients_cluster_tag_value" {
  value = "${module.nomad.nomad_clients_cluster_tag_value}"
}
