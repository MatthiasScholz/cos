#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and then the run-nomad script to configure and start
# Nomad in server mode. Note that this script assumes it's running in an AMI built from the Packer template in
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
  echo -e "echo -e '{\n\"credHelpers\": {\n\t\"${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com\": \"ecr-login\"\n\t}\n}' > /etc/docker/config.json" | sudo sh

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
  /opt/nomad/bin/run-nomad --server --num-servers "${num_servers}" --datacenter "${datacenter}"
}

configure_ecr_docker_credential_helper
setup_consul_and_nomad