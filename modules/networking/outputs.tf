output "subnet_ids" {
  value = "${aws_subnet.subn_services.*.id}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc_main.id}"
}
