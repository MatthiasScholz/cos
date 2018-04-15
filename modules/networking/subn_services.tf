# SERVICES subnets
resource "aws_subnet" "subn_services" {
  # one for each az
  count             = "${length(var.az_postfixes)}"
  vpc_id            = "${aws_vpc.vpc_main.id}"
  cidr_block        = "${var.ip_prefix}.${0 + count.index * 32}.0/19"
  availability_zone = "${var.region}${element(var.az_postfixes,count.index)}"

  tags {
    Name = "${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-SUBN-services"
  }
}

# route-table for the services subnets
resource "aws_route_table" "rtb_services" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  # one for each az
  count = "${length(var.az_postfixes)}"

  tags {
    Name = "${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-RTB-services"
  }
}

# association between the services subnets and the services routetable
resource "aws_route_table_association" "rtassoc_services" {
  # one for each az
  count          = "${length(var.az_postfixes)}"
  subnet_id      = "${element(aws_subnet.subn_services.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.rtb_services.*.id,count.index)}"
}

# this is the route to the egress_aws natgateway
resource "aws_route" "r_services_egress_aws_ngw" {
  # one for each az
  count                  = "${length(var.az_postfixes)}"
  route_table_id         = "${element(aws_route_table.rtb_services.*.id,count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.ngw_egress_aws.*.id,count.index)}"
}
