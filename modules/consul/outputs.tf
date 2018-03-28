output "asg_name_consul_servers" {
  value = "${module.consul_servers.asg_name}"
}

output "security_group_id_consul_servers" {
  value = "${module.consul_servers.security_group_id}"
}
