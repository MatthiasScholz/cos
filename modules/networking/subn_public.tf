# PUBLIC subnets
resource "aws_subnet" "subn_public" {
  # one for each az
  count             = "${length(var.az_postfixes)}"
  vpc_id            = "${aws_vpc.vpc_main.id}"
  cidr_block        = "${var.ip_prefix}.${128 + count.index}.0/24"
  availability_zone = "${var.region}${element(var.az_postfixes,count.index)}"

  tags {
    Name = "MNG-${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-SUBN-public"
  }
}

# route-table for the public subnet
resource "aws_route_table" "rtb_public" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  # one for each az
  count = "${length(var.az_postfixes)}"

  tags {
    Name = "MNG-${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-RTB-public"
  }
}

# association between the public subnets and the public routetable
resource "aws_route_table_association" "rtassoc_public" {
  # one for each az
  count          = "${length(var.az_postfixes)}"
  subnet_id      = "${element(aws_subnet.subn_public.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.rtb_public.*.id,count.index)}"
}

# this is the route to the internet
resource "aws_route" "r_public_inet" {
  # one for each az
  count                  = "${length(var.az_postfixes)}"
  route_table_id         = "${element(aws_route_table.rtb_public.*.id,count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw_main.id}"
}
