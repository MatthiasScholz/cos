# EGRESS PUBLIC subnets
resource "aws_subnet" "subn_egress_public" {
  # one for each az
  count             = "${length(var.az_postfixes)}"
  vpc_id            = "${aws_vpc.vpc_main.id}"
  cidr_block        = "${var.ip_prefix}.${148 + count.index}.0/24"
  availability_zone = "${var.region}${element(var.az_postfixes,count.index)}"

  tags {
    Name = "MNG-${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-${var.env_name}-SUBN-egress_public"
  }
}

# route-table for the egress_public subnets
resource "aws_route_table" "rtb_egress_public" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  # one for each az
  count = "${length(var.az_postfixes)}"

  tags {
    Name = "MNG-${var.stack_name}-${var.region}${element(var.az_postfixes,count.index)}-${var.env_name}-RTB-egress_public"
  }
}

# association between the egress_public subnets and the egress_public routetable
resource "aws_route_table_association" "rtassoc_egress_public" {
  # one for each az
  count          = "${length(var.az_postfixes)}"
  subnet_id      = "${element(aws_subnet.subn_egress_public.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.rtb_egress_public.*.id,count.index)}"
}

# this is the route to the internet
resource "aws_route" "r_egress_public_inet" {
  # one for each az
  count                  = "${length(var.az_postfixes)}"
  route_table_id         = "${element(aws_route_table.rtb_egress_public.*.id,count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw_main.id}"
}

# elastic ips needed for the natgateways
resource "aws_eip" "eip_egress_public" {
  # one for each az
  count = "${length(var.az_postfixes)}"
  vpc   = true
}

# the natgateways for egress public access
resource "aws_nat_gateway" "ngw_egress_public" {
  # one for each az
  count         = "${length(var.az_postfixes)}"
  allocation_id = "${element(aws_eip.eip_egress_public.*.id,count.index)}"
  subnet_id     = "${element(aws_subnet.subn_egress_public.*.id,count.index)}"
}
