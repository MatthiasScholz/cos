#!/bin/bash
# A script that prints the sshuttle login to the bastion server

set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

function log {
  local readonly level="$1"
  local readonly message="$2"
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
  local readonly message="$1"
  log "INFO" "$message"
}

function log_warn {
  local readonly message="$1"
  log "WARN" "$message"
}

function log_error {
  local readonly message="$1"
  log "ERROR" "$message"
}

function assert_is_installed {
  local readonly name="$1"

  if [[ ! $(command -v ${name}) ]]; then
    log_error "The binary '$name' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
}

function get_required_terraform_output {
  local readonly output_name="$1"
  local output_value

  output_value=$(terraform output -no-color "$output_name")

  if [[ -z "$output_value" ]]; then
    log_error "Unable to find a value for Terraform output $output_name"
    exit 1
  fi

  echo "$output_value"
}



function gen_sshuttle_login {
  local readonly ssh_key_name=$(get_required_terraform_output "ssh_key_name")
  local readonly bastion_ip=$(get_required_terraform_output "bastion_ip")
  local readonly vpc_cidr_block=$(get_required_terraform_output "vpc_cidr_block")

  echo "sshuttle -v -r ec2-user@"$bastion_ip" \
   -e 'ssh -v -o StrictHostKeyChecking=false -i ~/.ssh/"$ssh_key_name".pem' \
   -H "$vpc_cidr_block""
}

function run {
  assert_is_installed "terraform"
  assert_is_installed "sshuttle"
  cmd=$(gen_sshuttle_login)
  echo "calling $cmd"
  eval $cmd
}

run "$@"