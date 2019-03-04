output "asg_name_consul_servers" {
  value = "${module.consul_servers.asg_name}"
}

output "security_group_id_consul_servers" {
  value = "${module.consul_servers.security_group_id}"
}

output "consul_servers_cluster_tag_key" {
  value = "${module.consul_servers.cluster_tag_key}"
}

output "consul_servers_cluster_tag_value" {
  value = "${module.consul_servers.cluster_tag_value}"
}
