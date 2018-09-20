#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and the run-nomad script to configure and start Nomad
# in client mode. Note that this script assumes it's running in an AMI built from the Packer template in
# examples/nomad-consul-ami/nomad-consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# These variables are passed in via Terraform template interplation
/opt/consul/bin/run-consul --client --cluster-tag-key "${cluster_tag_key}" --cluster-tag-value "${cluster_tag_value}"
/opt/nomad/bin/run-nomad --client --datacenter "${datacenter}"

# Set envar for DNS name for EFS
export EFS_DNS_NAME="${efs_dns_name}"
echo -e "echo -e '\n# set envar for DNS name for EFS\nexport EFS_DNS_NAME=\"${efs_dns_name}\"' >> /etc/profile" | sudo sh
# Set envar for name of map bucket
echo -e "echo -e '\n# set envar for name of the mab bucket\nexport MAP_BUCKET_NAME=\"${map_bucket_name}\"' >> /etc/profile" | sudo sh

# Do the efs mount in case we know the EFS_DNS_NAME
if [ -n "$EFS_DNS_NAME" ];then
  echo "Mount efs target at: $EFS_DNS_NAME..."
  /usr/bin/mount_efs.sh
  echo "Mount efs target at: $EFS_DNS_NAME...done"
else
  echo "Don't mount efs on this machine, since no efs target is given (env-var EFS_DNS_NAME is not set)."
fi


# space separated list of device names
# TODO inject tf var
device_names=("/dev/xvde:/mnt/map1" "/dev/xvdf:/mnt/map2")

# TODO inject tf var
fs_type="xfs"
declare -A device_map


function parse_device_map () {
  for device_kv in ${device_names[*]}
  do

    echo $device_kv
    while IFS=':' read device mount_target; do
        echo "$device --> $mount_target"
        device_map["${device}"]="${mount_target}"
    done <<<"$device_kv"
  done
}

function print_device_map () {
  for device in ${!device_map[@]}
  do
    echo "$device --> ${device_map[${device}]}"
  done
}

function prepare_and_mount_device () {

  for device in ${!device_map[@]}
  do
    mount_target="${device_map[${device}]}"
    echo "Create mount_target $mount_target"
    sudo mkdir -p $mount_target

    mount_command="sudo mount $device $mount_target"
    formatted="$mount_command 2> /dev/null"

    echo "Create file-system on $device if needed"
    if eval $formatted; then
      echo "File system exists"
    else
      echo "File system does not exist ... will be created."
      sudo mkfs -t $fs_type $device -V -V
    fi

    if grep -q $mount_target /etc/fstab
    then
      echo "mountpoint already in /etc/fstab"
    else
      echo "Update /etc/fstab $device -> $mount_target"
      sudo echo -e "$device $mount_target $fs_type defaults 0 0" | sudo tee --append /etc/fstab
    fi

    echo "Mounting $device on $mount_target"
    sudo mount -a
  done
}

parse_device_map
print_device_map
prepare_and_mount_device
