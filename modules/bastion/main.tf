resource "aws_instance" "ec2_bastion" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ssh_key_name}"
  subnet_id     = "${var.subnet_id}"

  vpc_security_group_ids = ["${aws_security_group.sg_bastion.id}"]

  tags {
    Name = "${var.stack_name}-EC2-bastion${var.unique_postfix}"
  }
}

resource "aws_security_group" "sg_bastion" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.stack_name}-SG-bastion${var.unique_postfix}"
  description = "Security Group for basition server"

  tags {
    Name = "${var.stack_name}-SG-bastion${var.unique_postfix}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# grants access for all tcp but only to the services subnet
resource "aws_security_group_rule" "sgr_bastion_egAll" {
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  description = "egress all tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_bastion.id}"
}

locals {
  keys = "${keys(var.allowed_ssh_cidr_blocks)}"
}

resource "aws_security_group_rule" "sgr_bastion_ig_ssh" {
  count             = "${length(local.keys)}"
  description       = "${element(local.keys,count.index)}: igress ssh"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${lookup(var.allowed_ssh_cidr_blocks,element(local.keys,count.index),"0.0.0.0/32")}"]
  security_group_id = "${aws_security_group.sg_bastion.id}"
}

# elastic ips needed for the bastion
resource "aws_eip" "eip_bastion" {
  instance = "${aws_instance.ec2_bastion.id}"
  vpc      = true

  tags {
    Name = "${var.stack_name}-EIP-bastion${var.unique_postfix}"
  }
}
