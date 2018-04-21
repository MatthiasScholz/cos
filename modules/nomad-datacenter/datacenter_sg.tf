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
# grants access for all tcp but only to the services subnet
resource "aws_security_group_rule" "sgr_client_eg_all" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client.id}"
}


# Nomad Docker ports
resource "aws_security_group_rule" "sgr_client_ig_docker" {
  type              = "ingress"
  description       = "Nomad Dynamic Docker Ports"
  from_port         = 20000
  to_port           = 32000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client.id}"
}


# Fabio
# INGRESS
resource "aws_security_group_rule" "sgr_datacenter_ig_fabio_health" {
  type              = "ingress"
  description       = "ALB Target Group Health Check (fabio)"
  from_port         = 9998
  to_port           = 9998
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_datacenter.id}"
}

resource "aws_security_group_rule" "sgr_datacenter_ig_fabio" {
  type              = "ingress"
  description       = "Fabio Load Balancer"
  from_port         = 9999
  to_port           = 9999
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_datacenter.id}"
}

resource "aws_security_group_rule" "sgr_datacenter_ig_docker" {
  type              = "ingress"
  from_port         = 24007
  to_port           = 24007
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_datacenter.id}"
}

# EGRESS
# grants access for all tcp but only to the services subnet
resource "aws_security_group_rule" "sgr_datacenter_eg_all" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"



########################################
# Configuration of the GlusterFS ports #
########################################
resource "aws_security_group" "sg_client_glusterfs" {
  vpc_id      = "${var.vpc_id}"
  name        = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-SG-client-glusterfs"
  description = "security group that allows ingress access for the glusterfs."

  tags {
    Name = "MNG-${var.stack_name}-${var.aws_region}-${var.env_name}-SG-client-glusterfs"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# INGRESS
# FIXME: This might by collide with a Docker port nomad might select!
resource "aws_security_group_rule" "sgr_client_glusterfs_ig_rest" {
  description       = "REST"
  type              = "ingress"
  from_port         = 24007
  to_port           = 24007
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
<<<<<<< variant A
  security_group_id = "${aws_security_group.sg_client_glusterfs.id}"
>>>>>>> variant B
  security_group_id = "${aws_security_group.sg_datacenter.id}"
======= end
}

<<<<<<< variant A
# FIXME: This might by collide with a Docker port nomad might select!
resource "aws_security_group_rule" "sgr_client_glusterfs_ig_grpc" {
  description       = "gRPC"
  type              = "ingress"
  from_port         = 24008
  to_port           = 24008
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client_glusterfs.id}"
}
>>>>>>> variant B
# EGRESS
# grants access for all tcp but only to the services subnet
resource "aws_security_group_rule" "sgr_datacenter_eg_all" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
======= end


# Configure Bricks
# FIXME: Currently 3 bricks are configured. Every bricks gets on port.
#        Make it depended from the number of nomad clients
resource "aws_security_group_rule" "sgr_client_glusterfs_ig_bricks" {
  description       = "Bricks"
  type              = "ingress"
  from_port         = 49152
  to_port           = 49154
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
<<<<<<< variant A
  security_group_id = "${aws_security_group.sg_client_glusterfs.id}"
}


# GD2
# DISABLED resource "aws_security_group_rule" "sgr_client_glusterfs_ig_etcdtraffic" {
# DISABLED   description       = "etcd client traffic"
# DISABLED   type              = "ingress"
# DISABLED   from_port         = 2379
# DISABLED   to_port           = 2379
# DISABLED   protocol          = "tcp"
# DISABLED   cidr_blocks       = ["0.0.0.0/0"]
# DISABLED   security_group_id = "${aws_security_group.sg_client_glusterfs.id}"
# DISABLED }
# DISABLED
# DISABLED resource "aws_security_group_rule" "sgr_client_glusterfs_ig_etcpeer" {
# DISABLED   description       = "etcd peer communication"
# DISABLED   type              = "ingress"
# DISABLED   from_port         = 2380
# DISABLED   to_port           = 2380
# DISABLED   protocol          = "tcp"
# DISABLED   cidr_blocks       = ["0.0.0.0/0"]
# DISABLED   security_group_id = "${aws_security_group.sg_client_glusterfs.id}"
# DISABLED }


resource "aws_security_group_rule" "sgr_client_glusterfs_ig_nfs" {
  description       = "NFS"
  type              = "ingress"
  from_port         = 38465
  to_port           = 38467
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client_glusterfs.id}"
}

resource "aws_security_group_rule" "sgr_client_glusterfs_ig_portmapper_tcp" {
  description       = "NFS Portmapper TCP"
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client_glusterfs.id}"
}

resource "aws_security_group_rule" "sgr_client_glusterfs_ig_portmapper_udp" {
  description       = "NFS Portmapper UDP"
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client_glusterfs.id}"
}

# FIXME: Might not be needed: http://sysaix.com/how-to-setup-a-replicated-glusterfs-cluster-on-aws-ec2-google-cloud-platform-azure
resource "aws_security_group_rule" "sgr_client_glusterfs_ig_portmapper" {
  description       = "Portmapper"
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_client_glusterfs.id}"
>>>>>>> variant B
  security_group_id = "${aws_security_group.sg_datacenter.id}"
======= end
}
