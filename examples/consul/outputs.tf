output "asg_name_consul_servers" {
  value = "${module.consul.asg_name_consul_servers}"
}

output "security_group_id_consul_servers" {
  value = "${module.consul.security_group_id_consul_servers}"
}

output "consul_servers_cluster_tag_key" {
  value = "${module.consul.consul_servers_cluster_tag_key}"
}

output "consul_servers_cluster_tag_value" {
  value = "${module.consul.consul_servers_cluster_tag_value}"
}
