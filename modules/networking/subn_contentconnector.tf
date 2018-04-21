# CONTENTCONNECTOR subnets
resource "aws_subnet" "subn_contentconnector" {
  # one for each az
  count             = "${length(var.az_postfixes)}"
  vpc_id            = "${aws_vpc.vpc_main.id}"
  cidr_block        = "${var.ip_prefix}.${132 + (count.index*2)}.0/23"
  availability_zone = "${var.region}${element(var.az_postfixes,count.index)}"

  tags {
    Name = "MNG-${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-${var.env_name}-SUBN-contentconnector"
  }
}

# route-table for the contentconnector subnets
resource "aws_route_table" "rtb_contentconnector" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  # one for each az
  count = "${length(var.az_postfixes)}"

  tags {
    Name = "MNG-${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-${var.env_name}-RTB-contentconnector"
  }
}

# association between the contentconnector subnets and the contentconnector routetable
resource "aws_route_table_association" "rtassoc_contentconnector" {
  # one for each az
  count          = "${length(var.az_postfixes)}"
  subnet_id      = "${element(aws_subnet.subn_contentconnector.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.rtb_contentconnector.*.id,count.index)}"
}

# this is the route to the egress_public natgateway
resource "aws_route" "r_egress_public_ngw" {
  # one for each az
  count                  = "${length(var.az_postfixes)}"
  route_table_id         = "${element(aws_route_table.rtb_contentconnector.*.id,count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.ngw_egress_public.*.id,count.index)}"
}
