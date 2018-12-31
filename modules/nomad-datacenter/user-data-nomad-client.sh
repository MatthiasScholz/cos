#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and the run-nomad script to configure and start Nomad
# in client mode. Note that this script assumes it's running in an AMI built from the Packer template in
# examples/nomad-consul-ami/nomad-consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

readonly SCRIPT_DIR="$(cd "$(dirname "$${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

function log {
  local readonly level="$1"
  local readonly message="$2"
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "$${timestamp} [$${level}] [$SCRIPT_NAME] $${message}"
}

function log_info {
  local readonly message="$1"
  log "INFO" "$message"
}

function configure_ecr_docker_credential_helper (){ 
  # These variables are passed in via Terraform template interplation
  log_info "Creating /etc/docker/config.json containing the credential helper for docker login to ECR"
  echo -e "echo -e '{\n\"credHelpers\": {\n\t\"${aws_account_id}.dkr.ecr.\"${aws_region}\".amazonaws.com\": \"ecr-login\"\n\t}\n}' > /etc/docker/config.json" | sudo sh  

  log_info "Copy /etc/docker/config.json to /home/ec2-user/.docker/config.json"
  cp /etc/docker/config.json /home/ec2-user/.docker/
  chown ec2-user /home/ec2-user/.docker/config.json
  chgrp ec2-user /home/ec2-user/.docker/config.json
}


function setup_consul_and_nomad (){ 
  # These variables are passed in via Terraform template interplation
  log_info "Configuring consul."
  /opt/consul/bin/run-consul --client --cluster-tag-key "${cluster_tag_key}" --cluster-tag-value "${cluster_tag_value}"
  log_info "Configuring nomad."
  /opt/nomad/bin/run-nomad --client --datacenter "${datacenter}"
}

function configure_efs() {
  # Set envar for DNS name for EFS
  export EFS_DNS_NAME="${efs_dns_name}"
  echo -e "echo -e '\n# set envar for DNS name for EFS\nexport EFS_DNS_NAME=\"${efs_dns_name}\"' >> /etc/profile" | sudo sh
  # Set envar for name of map bucket
  echo -e "echo -e '\n# set envar for name of the mab bucket\nexport MAP_BUCKET_NAME=\"${map_bucket_name}\"' >> /etc/profile" | sudo sh

  # Do the efs mount in case we know the EFS_DNS_NAME
  if [ -n "$EFS_DNS_NAME" ];then
    log_info "Mount efs target at: $EFS_DNS_NAME..."
    /usr/bin/mount_efs.sh
    log_info "Mount efs target at: $EFS_DNS_NAME...done"
  else
    log_info "Don't mount efs on this machine, since no efs target is given (env-var EFS_DNS_NAME is not set)."
  fi
}



############### Mounting of devices (i.e. EBS volumes) #############################################
# Space separated list of device to mount target entries.
# A device to mount target entry is a key value pair (separated by ' ').
# key ... is the name of the device (i.e. /dev/xvdf)
# value ... is the name of the mount target (i.e. /mnt/map1)
# Example: "/dev/xvde:/mnt/map1 /dev/xvdf:/mnt/map2"
device_to_mount_target=("${device_to_mount_target_map}")
fs_type="${fs_type}"

# map containing the device to mount-target mapping.
declare -A device_map

# Function that parses the device_map parameter,
# expecting the parameter consists of a string which contains a
# list of key value pairs. The key and value have to be separated by ':'.
# The key value pairs have to be separated by ' '.
# The key is the name of the device (i.e. /dev/xvdf) and the value
# is the mount-target (i.e. /mnt/map).
# After Parsing the map of device -> mount-target is stored in device_map
function parse_device_map () {
  for device_kv in $${device_to_mount_target[*]}
  do
    while IFS=':' read device mount_target; do
        device_map["$${device}"]="$${mount_target}"
    done <<<"$device_kv"
  done
}

# Function that prints the parameter device_map.
function print_device_map () {
  log_info "Available device to mount-target entries:"
  for device in $${!device_map[@]}
  do
    log_info "\tDevice: $device will be mounted to $${device_map[$${device}]}"
  done
}

# Function that tries to mount all devices which are not already mounted.
# If needed a file-system is created on them as well.
function prepare_and_mount_device () {

  for device in $${!device_map[@]}
  do
    mount_target="$${device_map[$${device}]}"
    log_info "Processing $device -> $mount_target"

    log_info "\tCreate mount_target $mount_target"
    sudo mkdir -p $mount_target

    mount_command="sudo mount $device $mount_target"
    formatted="$mount_command 2> /dev/null"

    log_info "\tCreate file-system on $device if needed"
    if eval $formatted; then
      log_info "\t\tFile system exists"
    else
      log_info "\t\tFile system does not exist ... will be created."
      sudo mkfs -t $fs_type $device -V
    fi

    if grep -q $mount_target /etc/fstab
    then
      log_info "\tMountpoint already in /etc/fstab."
    else
      log_info "\tUpdate /etc/fstab $device -> $mount_target"
      sudo echo -e "$device $mount_target $fs_type defaults 0 0" | sudo tee --append /etc/fstab
    fi

    log_info "\tMounting $device on $mount_target"
    sudo mount -a
  done
}

configure_ecr_docker_credential_helper
setup_consul_and_nomad
configure_efs

# Mount EBS devices
parse_device_map
print_device_map
prepare_and_mount_device
