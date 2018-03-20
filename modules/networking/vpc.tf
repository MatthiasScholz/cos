#the main vpc itself
resource "aws_vpc" "vpc_main" {
  cidr_block           = "${var.ip_prefix}.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags {
    Name = "${var.stack_name}-VPC-main"
  }
}

locals {
  dns_ip = "${var.ip_prefix}.8.8"
}

#dhcp options
resource "aws_vpc_dhcp_options" "vpc_main_dns" {
  domain_name         = "nomad-${var.region}"
  domain_name_servers = ["${local.dns_ip}", "AmazonProvidedDNS"]

  tags {
    Name = "${var.stack_name}-DOPT-vpc"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc_main_dns_resolver" {
  vpc_id          = "${aws_vpc.vpc_main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc_main_dns.id}"
}

# the internet gateway
resource "aws_internet_gateway" "igw_main" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "${var.stack_name}-IGW-main"
  }
}
