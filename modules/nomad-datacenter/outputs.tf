output "num_nodes" {
  value = "${module.data_center.cluster_size}"
}

output "asg_name" {
  value = "${module.data_center.asg_name}"
}

output "aws_region" {
  value = "${var.aws_region}"
}

output "cluster_tag_value" {
  value = "${module.data_center.cluster_tag_value}"
}
