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

output "nomad_clients_public_services_cluster_tag_value" {
  value = "${module.nomad-infra.nomad_clients_public_services_cluster_tag_value}"
}

output "nomad_ui_alb_dns" {
  value = "${module.nomad-infra.nomad_ui_alb_dns_name}"
}

output "curl_nomad_ui" {
  value = "curl http://${module.nomad-infra.nomad_ui_alb_dns_name}/ui/jobs"
}

output "export_nomad_cmd" {
  value = "export NOMAD_ADDR=\"http://${module.nomad-infra.nomad_ui_alb_dns_name}\""
}

output "consul_ui_alb_dns" {
  value = "${module.nomad-infra.consul_ui_alb_dns_name}"
}

output "curl_consul_ui" {
  value = "curl http://${module.nomad-infra.consul_ui_alb_dns_name}/ui"
}

output "fabio_ui_alb_dns" {
  value = "${module.nomad-infra.fabio_ui_alb_dns_name}"
}

output "curl_fabio_ui" {
  value = "curl http://${module.nomad-infra.fabio_ui_alb_dns_name}"
}

output "curl_ping_service" {
  value = "watch -x curl -s http://${module.networking.alb_public_services_dns}/ping"
}

output "ingress_alb_dns" {
  value = "${module.networking.alb_public_services_dns}"
}

output "bastion_ip" {
  value = "${module.bastion.bastion_ip}"
}

output "ssh_login" {
  value = "ssh ec2-user@${module.bastion.bastion_ip} -i ~/.ssh/${module.nomad-infra.ssh_key_name}.pem"
}

output "ssh_key_name" {
  value = "${module.nomad-infra.ssh_key_name}"
}

output "vpc_id" {
  value = "${module.nomad-infra.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${module.networking.vpc_cidr_block}"
}

output "cluster_prefix" {
  value = "${module.nomad-infra.cluster_prefix}"
}

output "consul_servers_cluster_tag_key" {
  value = "${module.nomad-infra.consul_servers_cluster_tag_key}"
}

output "consul_servers_cluster_tag_value" {
  value = "${module.nomad-infra.consul_servers_cluster_tag_value}"
}

output "nomad_ui_alb_dns_name" {
  value = "${module.nomad-infra.nomad_ui_alb_dns_name}"
}

output "nomad_ui_alb_https_targetgroup_arn" {
  value = "${module.nomad-infra.nomad_ui_alb_https_targetgroup_arn}"
}

output "nomad_ui_alb_https_listener_arn" {
  value = "${module.nomad-infra.nomad_ui_alb_https_listener_arn}"
}

output "consul_ui_alb_dns_name" {
  value = "${module.nomad-infra.consul_ui_alb_dns_name}"
}

output "consul_ui_alb_https_targetgroup_arn" {
  value = "${module.nomad-infra.consul_ui_alb_https_targetgroup_arn}"
}

output "consul_ui_alb_https_listener_arn" {
  value = "${module.nomad-infra.consul_ui_alb_https_listener_arn}"
}

output "fabio_ui_alb_dns_name" {
  value = "${module.nomad-infra.fabio_ui_alb_dns_name}"
}

output "fabio_ui_alb_https_targetgroup_arn" {
  value = "${module.nomad-infra.fabio_ui_alb_https_targetgroup_arn}"
}

output "fabio_ui_alb_https_listener_arn" {
  value = "${module.nomad-infra.fabio_ui_alb_https_listener_arn}"
}

output "dc-public-services_alb_https_targetgroup_arn" {
  value = "${module.nomad-infra.dc-public-services_alb_https_targetgroup_arn}"
}

output "dc-private-services_alb_https_targetgroup_arn" {
  value = "${module.nomad-infra.dc-private-services_alb_https_targetgroup_arn}"
}

output "dc-backoffice_alb_https_targetgroup_arn" {
  value = "${module.nomad-infra.dc-backoffice_alb_https_targetgroup_arn}"
}
