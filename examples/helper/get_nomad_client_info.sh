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


function get_nomad_client_info {
  local aws_region
  local cluster_tag_value
  local instances
  local profile="--profile $1"

  if [ -z "$1" ];then
    profile=""
  fi 

  aws_region=$(get_required_terraform_output "aws_region")
  cluster_tag_value=$(get_required_terraform_output "nomad_clients_cluster_tag_value")

  if [ -z "$cluster_tag_value" ];then
    cluster_tag_value="$(get_required_terraform_output "nomad_servers_cluster_tag_value")-client"
  fi

  

  instances=$(aws ec2 describe-instances \
    --region "$aws_region" \
    $profile \
    --filter "Name=tag:Name,Values=$cluster_tag_value" "Name=instance-state-name,Values=running")

  echo "$instances" | jq -r '.Reservations[].Instances[] | {id:.InstanceId,ip:.PublicIpAddress,pip:.PrivateIpAddress}'
}

function print_nomad_client_info_table {
  local profile="$1"
  local readonly client_info=($(get_nomad_client_info $profile))
  local readonly client_info_list=($(echo ${client_info[@]} | jq -r '.ip, .id, .pip'))
  local readonly client_info_list_entries="${#client_info_list[@]}"

  local client_info_table=()
  client_info_table+=("ISTANCE_ID\tINSTANCE_IP\t\tINSTANCE_IP (private)")
  for (( i=0; i<"$client_info_list_entries"; i+=3 )); do
    local client_id=${client_info_list[i]}
    local client_ip=${client_info_list[i+1]}
    local p_client_ip=${client_info_list[i+2]}
    client_info_table+=("$client_id\t$client_ip\t$p_client_ip")
  done 

  local readonly client_info_table_str=$(join "\n" "${client_info_table[@]}")
  echo -e "$client_info_table_str"
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

  print_nomad_client_info_table "$profile"
}

run "$@"