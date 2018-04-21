#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and the run-nomad script to configure and start Nomad
# in client mode. Note that this script assumes it's running in an AMI built from the Packer template in
# examples/nomad-consul-ami/nomad-consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Configure GlusterFS
# .NOTE: The device name has to match with the terraform ebs_block_device settings in the aws_lauch_configuration!
echo "[INFO] Prepare Filesystem for GlusterFS"
mkfs.xfs /dev/xvdf
mkdir -p /data/glusterfs
echo "/dev/sdf /data/glusterfs xfs defaults 0 1" >> /etc/fstab
mount -a

# DEBUG generate a test brick folder to facilitate playing around with GlusterFS.
mkdir -p /data/clusterfs/test-brick
chmod a+rw -R /data/clusterfs/test-brick

# These variables are passed in via Terraform template interplation
/opt/consul/bin/run-consul --client --cluster-tag-key "${cluster_tag_key}" --cluster-tag-value "${cluster_tag_value}"
/opt/nomad/bin/run-nomad --client --datacenter "${datacenter}"
