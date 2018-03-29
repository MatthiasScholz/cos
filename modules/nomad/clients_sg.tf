# Every client can get requests for the automatically assigned ports for each nomad job
# ( https://www.nomadproject.io/docs/job-specification/network.html ),
# for example fabio will use consul to figure out the port mapping and direct requests directly to this ports.
# Currently fabio is running on every client and can get requests forwarded from the load balancer,
# hence the fabio port needs to be open for all clients.
# Every client can get requests for the automatically assigned ports for each nomad job,
# for example fabio will use consul to figure out the port mapping and direct requests directly to this ports.
resource "aws_security_group" "sg_client" {
  vpc_id      = "${var.vpc_id}"
  name        = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-SG-client-nomad"
  description = "Security group that allows ingress access for the nomad service handling and docker ports."

  tags {
    Name = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-SG-client-nomad"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# INGRESS
resource "aws_security_group_rule" "sgr_client_ig_fabio_health" {
  type              = "ingress"
  description       = "ALB Target Group Health Check (fabio)"
  from_port         = 9998
  to_port           = 9998
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client.id}"
}

resource "aws_security_group_rule" "sgr_client_ig_fabio" {
  type              = "ingress"
  description       = "Fabio Load Balancer"
  from_port         = 9999
  to_port           = 9999
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client.id}"
}

resource "aws_security_group_rule" "sgr_client_ig_docker" {
  type              = "ingress"
  description       = "Nomad Dynamic Docker Ports"
  from_port         = 20000
  to_port           = 32000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client.id}"
}

# rule that grants TCP ingress access from nomad-server to nomad-clients
resource "aws_security_group_rule" "sgr_client_tcp_ig_from_nomad_server" {
  type                     = "ingress"
  description              = "tcp ingress from Nomad Servers"
  from_port                = 4646
  to_port                  = 4648
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.sg_server.id}"
  security_group_id        = "${aws_security_group.sg_client.id}"
}

# rule that grants UDP ingress access from nomad-server to nomad-clients
resource "aws_security_group_rule" "sgr_client_udp_ig_from_nomad_server" {
  type                     = "ingress"
  description              = "udp ingress from Nomad Servers"
  from_port                = 4648
  to_port                  = 4648
  protocol                 = "udp"
  source_security_group_id = "${aws_security_group.sg_server.id}"
  security_group_id        = "${aws_security_group.sg_client.id}"
}

# EGRESS
# grants access for all tcp but only to the services subnet
resource "aws_security_group_rule" "sgr_client_eg_all" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client.id}"
}
