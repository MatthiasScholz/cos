# EGRESS AWS subnets
resource "aws_subnet" "subn_egress_aws" {
  # one for each az
  count             = length(var.az_postfixes)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = "${var.ip_prefix}.${144 + count.index}.0/24"
  availability_zone = "${var.region}${element(var.az_postfixes, count.index)}"

  tags = {
    Name = "MNG-${var.stack_name}-${var.region}${element(var.az_postfixes, count.index)}-${var.env_name}-SUBN-egress_aws"
  }
}

locals {
  # This variable contains the cidr's that should be allowed to be routed to per route-table (per availability zone)
  # This variable is list of lists. Each element of the list contains two elements. First the id of the route-table the route should be added to,
  # second the destination cidr for that route.
  # Example: (one rtb-id, three cidr's: setproduct(["rtb-00415f0251d6bfa34"],["72.0.0.0/8","75.0.0.0/8","174.0.0.0/8"]) )
  # [
  #  [
  #    "rtb-00415f0251d6bfa34",
  #    "72.0.0.0/8"
  #  ],
  #  [
  #    "rtb-00415f0251d6bfa34",
  #    "75.0.0.0/8"
  #  ],
  #  [
  #    "rtb-00415f0251d6bfa34",
  #    "174.0.0.0/8"
  #  ]
  # ]
  cidr_per_route_table_id = setproduct(aws_route_table.rtb_egress_aws.*.id, var.aws_ip_address_ranges)
}


# route-table for the egress_aws subnets
resource "aws_route_table" "rtb_egress_aws" {
  vpc_id = aws_vpc.vpc_main.id

  # one for each az
  count = length(var.az_postfixes)

  tags = {
    Name = "MNG-${var.stack_name}-${var.region}${element(var.az_postfixes, count.index)}-${var.env_name}-RTB-egress_aws"
  }
}

# association between the egress_aws subnets and the egress_aws routetable
resource "aws_route_table_association" "rtassoc_egress_aws" {
  # one for each az
  count          = length(var.az_postfixes)
  subnet_id      = element(aws_subnet.subn_egress_aws.*.id, count.index)
  route_table_id = element(aws_route_table.rtb_egress_aws.*.id, count.index)
}

# this is the route to the aws service ip-ranges
resource "aws_route" "r_egress_aws_ips" {
  # one for each az
  count = length(local.cidr_per_route_table_id)

  route_table_id         = element(element(local.cidr_per_route_table_id, count.index), 0)
  destination_cidr_block = element(element(local.cidr_per_route_table_id, count.index), 1)
  gateway_id             = aws_internet_gateway.igw_main.id
}

# elastic ips needed for the egress_aws natgateways
resource "aws_eip" "eip_egress_aws" {
  # one for each az
  count = length(var.az_postfixes)
  vpc   = true
}

# the natgateways for egress aws access
resource "aws_nat_gateway" "ngw_egress_aws" {
  # one for each az
  count         = length(var.az_postfixes)
  allocation_id = element(aws_eip.eip_egress_aws.*.id, count.index)
  subnet_id     = element(aws_subnet.subn_egress_aws.*.id, count.index)
}

