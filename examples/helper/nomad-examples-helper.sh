#!/bin/bash
# A script that is meant to be used with the Nomad cluster examples to:
#
# 1. Wait for the Nomad server cluster to come up.
# 2. Print out the IP addresses of the Nomad servers.
# 3. Print out some example commands you can run against your Nomad servers.

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

function get_all_nomad_server_ips {
  local readonly profile=$1
  local expected_num_nomad_servers
  expected_num_nomad_servers=$(get_required_terraform_output "num_nomad_servers")

  log_info "Looking up public IP addresses for $expected_num_nomad_servers Nomad server EC2 Instances."

  local ips
  local i

  for (( i=1; i<="$MAX_RETRIES"; i++ )); do
    ips=($(get_nomad_server_ips "$profile"))
    if [[ "${#ips[@]}" -eq "$expected_num_nomad_servers" ]]; then
      log_info "Found all $expected_num_nomad_servers public IP addresses!"
      echo "${ips[@]}"
      return
    else
      log_warn "Found ${#ips[@]} of $expected_num_nomad_servers public IP addresses. Will sleep for $SLEEP_BETWEEN_RETRIES_SEC seconds and try again."
      sleep "$SLEEP_BETWEEN_RETRIES_SEC"
    fi
  done

  log_error "Failed to find the IP addresses for $expected_num_nomad_servers Nomad server EC2 Instances after $MAX_RETRIES retries."
  exit 1
}

function wait_for_all_nomad_servers_to_register {
  local readonly server_ips=($@)
  local readonly server_ip="${server_ips[0]}"

  local expected_num_nomad_servers
  expected_num_nomad_servers=$(get_required_terraform_output "num_nomad_servers")

  log_info "Waiting for $expected_num_nomad_servers Nomad servers to register in the cluster"

  for (( i=1; i<="$MAX_RETRIES"; i++ )); do
    log_info "Running 'nomad server-members' command against server at IP address $server_ip"
    # Intentionally use local and readonly here so that this script doesn't exit if the nomad server-members or grep
    # commands exit with an error.
    local readonly members=$(nomad server-members -address="http://$server_ip:4646")
    local readonly alive_members=$(echo "$members" | grep "alive")
    local readonly num_nomad_servers=$(echo "$alive_members" | wc -l | tr -d ' ')

    if [[ "$num_nomad_servers" -eq "$expected_num_nomad_servers" ]]; then
      log_info "All $expected_num_nomad_servers Nomad servers have registered in the cluster!"
      return
    else
      log_info "$num_nomad_servers out of $expected_num_nomad_servers Nomad servers have registered in the cluster."
      log_info "Sleeping for $SLEEP_BETWEEN_RETRIES_SEC seconds and will check again."
      sleep "$SLEEP_BETWEEN_RETRIES_SEC"
    fi
  done

  log_error "Did not find $expected_num_nomad_servers Nomad servers registered after $MAX_RETRIES retries."
  exit 1
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
  cluster_tag_key=$(get_required_terraform_output "nomad_servers_cluster_tag_key")
  cluster_tag_value=$(get_required_terraform_output "nomad_servers_cluster_tag_value")

  log_info "Fetching public IP addresses for EC2 Instances in $aws_region with tag $cluster_tag_key=$cluster_tag_value"

  instances=$(aws ec2 describe-instances \
    --region "$aws_region" \
    $profile \
    --filter "Name=tag:$cluster_tag_key,Values=$cluster_tag_value" "Name=instance-state-name,Values=running")

  echo "$instances" | jq -r '.Reservations[].Instances[].PublicIpAddress'
}

function print_instructions {
  local readonly server_ips=($@)
  local readonly server_ip="${server_ips[0]}"

  local instructions=()
  instructions+=("\nYour Nomad servers are running at the following IP addresses:\n\n${server_ips[@]/#/    }\n")  
  instructions+=("Some commands for you to try:\n")
  instructions+=("Configure ip of nomad-server:\texport NOMAD_ADDR=http://$server_ip:4646")
  instructions+=("Open nomad ui:\t\t\tnomad ui")
  instructions+=("Watch servers:\t\t\twatch -x nomad server-members")
  instructions+=("Watch nodes:\t\t\twatch -x nomad node-status")
  instructions+=("Deploy fabio-loadbalancer:\tnomad run $SCRIPT_DIR/fabio.nomad")
  instructions+=("Deploy ping_service:\t\tnomad run $SCRIPT_DIR/ping_service.nomad")
  instructions+=("Remove ping_service:\t\tnomad stop ping_service")
  instructions+=("Watch status of ping_service:\twatch -x nomad status ping_service\n")

  local instructions_str
  instructions_str=$(join "\n" "${instructions[@]}")

  echo -e "$instructions_str"
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

  local server_ips
  server_ips=$(get_all_nomad_server_ips "$profile")

  log_info "Public ips: $server_ips"

  wait_for_all_nomad_servers_to_register "$server_ips"
  print_instructions "$server_ips"
}

run "$@"