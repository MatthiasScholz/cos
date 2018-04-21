output "num_nomad_servers" {
  value = "${module.nomad_servers.cluster_size}"
}

output "asg_name_nomad_servers" {
  value = "${module.nomad_servers.asg_name}"
}

output "launch_config_name_nomad_servers" {
  value = "${module.nomad_servers.launch_config_name}"
}

output "iam_role_arn_nomad_servers" {
  value = "${module.nomad_servers.iam_role_arn}"
}

output "iam_role_id_nomad_servers" {
  value = "${module.nomad_servers.iam_role_id}"
}

output "security_group_id_nomad_servers" {
  value = "${aws_security_group.sg_server.id}"
}

output "aws_region" {
  value = "${var.aws_region}"
}

output "nomad_servers_cluster_tag_key" {
  value = "${module.nomad_servers.cluster_tag_key}"
}

output "nomad_servers_cluster_tag_value" {
  value = "${module.nomad_servers.cluster_tag_value}"
}
