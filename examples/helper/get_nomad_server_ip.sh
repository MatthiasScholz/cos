#!/bin/bash
# A script that prints the public-ip of the nomad servers

set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

readonly MAX_RETRIES=30
readonly SLEEP_BETWEEN_RETRIES_SEC=10

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

#
# Usage: join SEPARATOR ARRAY
#
# Joins the elements of ARRAY with the SEPARATOR character between them.
#
# Examples:
#
# join ", " ("A" "B" "C")
#   Returns: "A, B, C"
#
function join {
  local readonly separator="$1"
  shift
  local readonly values=("$@")

  printf "%s$separator" "${values[@]}" | sed "s/$separator$//"
}



function get_nomad_server_ips {
  local aws_region
  local cluster_tag_key
  local cluster_tag_value
  local instances
  local profile="--profile $1"

  if [ -z "$1" ];then
    profile=""
  fi 

  aws_region=$(get_required_terraform_output "aws_region")
  cluster_tag_value=$(get_required_terraform_output "nomad_servers_cluster_tag_value")

  instances=$(aws ec2 describe-instances \
    --region "$aws_region" \
    $profile \
    --filter "Name=tag:Name,Values=$cluster_tag_value" "Name=instance-state-name,Values=running")

  echo "$instances" | jq -r '.Reservations[].Instances[].PublicIpAddress'
}

function get_aws_profile() {
  # name of the profile defined in your ~/.aws/credential file

  profile="$AWS_PROFILE"

  # check cmd param, if set it will overwrite the env variable
  if [ ! -z "$1" ];then
    profile="$1"
  fi 

  echo "$profile"
}


function run {
  profile=$(get_aws_profile "$1" )
  if [ -z "$profile" ];then
    echo "Error AWS profile missing."
    echo -e "\tYou can specify it setting the env var AWS_PROFILE or"
    echo -e "\tby calling the script with the according parameter."
    exit 1
  fi 

  assert_is_installed "aws"
  assert_is_installed "jq"
  assert_is_installed "terraform"
  assert_is_installed "nomad"

  local readonly server_ips=($(get_nomad_server_ips "$profile"))
  local readonly num_server_ips="${#server_ips[@]}"

  if [ "$num_server_ips" -eq 0 ];then
    log_error "No server ips found"
    exit 1
  fi 
  local readonly server_ip="${server_ips[0]}"

  if [ -z "$server_ip" ];then
    log_error "No server found"
    exit 1
  fi

  echo -e "$server_ip"  
}

run "$@"