output "subnet_ids" {
  value = "${aws_subnet.subn_services.*.id}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc_main.id}"
}

output "alb_public_services_arn" {
  value = "${aws_alb.alb_public_services.arn}"
}

output "alb_backoffice_nomad_arn" {
  value = "${aws_alb.alb_backoffice_nomad.arn}"
}

output "alb_backoffice_consul_arn" {
  value = "${aws_alb.alb_backoffice_consul.arn}"
}

output "alb_backoffice_fabio_arn" {
  value = "${aws_alb.alb_backoffice_fabio.arn}"
}
