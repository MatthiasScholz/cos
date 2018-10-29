# Every client can get requests for the automatically assigned ports for each nomad job
# ( https://www.nomadproject.io/docs/job-specification/network.html ),
# for example fabio will use consul to figure out the port mapping and direct requests directly to this ports.
# Currently fabio is running on every client and can get requests forwarded from the load balancer,
# hence the fabio port needs to be open for all clients.
# Every client can get requests for the automatically assigned ports for each nomad job,
# for example fabio will use consul to figure out the port mapping and direct requests directly to this ports.
resource "aws_security_group" "sg_datacenter" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.stack_name}-${var.datacenter_name}${var.unique_postfix}"
  description = "Security group that allows ingress access for the nomad service handling and docker ports."

  tags {
    Name = "${var.stack_name}-${var.datacenter_name}${var.unique_postfix}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EGRESS
# grants access on all ports for all protocols
resource "aws_security_group_rule" "sgr_datacenter_eg_all" {
  type              = "egress"
  description       = "egress all protocols all ports"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_datacenter.id}"
}
