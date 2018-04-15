#!/bin/bash
# A script that waits until 4 Nomad clients (leaders) are available.

set -e

readonly MAX_RETRIES=30
readonly SLEEP_BETWEEN_RETRIES_SEC=10

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

function wait_for_nomad_clients {
  local readonly nomad_ui_alb_dns=$1
  local readonly num_expected_clients=$2

  log_info "Waiting for $num_expected_clients Nomad clients to get ready in the cluster"

  for (( i=1; i<="$MAX_RETRIES"; i++ )); do
    log_info "Running 'nomad node-status' command against nomad behind dns $nomad_ui_alb_dns"
    # Intentionally use local and readonly here so that this script doesn't exit if the nomad node-status or grep
    # commands exit with an error.
    local readonly members=$(nomad node-status -address="http://$nomad_ui_alb_dns")
    local readonly alive_members=$(echo "$members" | grep "ready")    
    local readonly num_nomad_clients=$(echo "$alive_members" | wc -l | tr -d ' ')


    if [[ "$num_nomad_clients" -eq "$num_expected_clients" ]]; then
      log_info "All $num_expected_clients Nomad clients have registered in the cluster!"
      return
    else
      log_info "$num_nomad_clients out of $num_expected_clients Nomad clients have registered in the cluster."
      log_info "Sleeping for $SLEEP_BETWEEN_RETRIES_SEC seconds and will check again."
      sleep "$SLEEP_BETWEEN_RETRIES_SEC"
    fi
  done

  log_error "Did not find $num_expected_clients Nomad clients registered after $MAX_RETRIES retries."
  exit 1
}

function run {
  assert_is_installed "terraform"
  assert_is_installed "nomad"

  local readonly num_expected_clients=4

  local readonly nomad_ui_alb_dns=$(get_required_terraform_output "nomad_ui_alb_dns")
  wait_for_nomad_clients "$nomad_ui_alb_dns" "$num_expected_clients"
}

run "$@"