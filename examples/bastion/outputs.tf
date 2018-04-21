output "bastion_ip" {
  value = "${module.bastion.bastion_ip}"
}

output "ssh_login" {
  value = "ssh ec2-user@${module.bastion.bastion_ip} -i ~/.ssh/${module.bastion.ssh_key_name}.pem"
}
