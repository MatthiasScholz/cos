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

output "nomad_clients_public_services_cluster_tag_value" {
  value = "${module.dc-public-services.cluster_tag_value}"
}

output "nomad_ui_alb_dns" {
  value = "${module.ui-access.nomad_ui_alb_dns}"
}

output "consul_ui_alb_dns" {
  value = "${module.ui-access.consul_ui_alb_dns}"
}

output "fabio_ui_alb_dns" {
  value = "${module.ui-access.fabio_ui_alb_dns}"
}

output "vpc_id" {
  value = "${var.vpc_id}"
}

output "ssh_key_name" {
  value = "${var.ssh_key_name}"
}

output "cluster_prefix" {
  value = "${module.dc-public-services.cluster_prefix}"
}

output "dc-public-services_sg_id" {
  value = "${module.dc-public-services.sg_datacenter_id}"
}

output "dc-private-services_sg_id" {
  value = "${module.dc-private-services.sg_datacenter_id}"
}

output "dc-backoffice_sg_id" {
  value = "${module.dc-backoffice.sg_datacenter_id}"
}

