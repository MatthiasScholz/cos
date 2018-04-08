output "bastion_ip" {
  value = "${aws_instance.ec2_bastion.public_ip}"
}

output "ssh_key_name" {
  value = "${var.ssh_key_name}"
}
