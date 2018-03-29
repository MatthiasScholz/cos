#!/bin/bash
# A script that prints the public-ip of the nomad servers

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


function print_ui_alb_table {
  local readonly nomad_ui_alb_dns=$(get_required_terraform_output "nomad_ui_alb_dns")
  local readonly fabio_ui_alb_dns=$(get_required_terraform_output "fabio_ui_alb_dns")
  local readonly consul_ui_alb_dns=$(get_required_terraform_output "consul_ui_alb_dns")

  local ui_alb_table=()
  ui_alb_table+=("UI\tALB-DNS\t\t\t\t\t\t\t\t\tLink")
  ui_alb_table+=("nomad\t${nomad_ui_alb_dns}\thttp://${nomad_ui_alb_dns}")
  ui_alb_table+=("consul\t${consul_ui_alb_dns}\thttp://${consul_ui_alb_dns}")
  ui_alb_table+=("fabio\t${fabio_ui_alb_dns}\thttp://${fabio_ui_alb_dns}")

  local readonly ui_alb_table_str=$(join "\n" "${ui_alb_table[@]}")
  echo -e "$ui_alb_table_str"
}

function run {
  assert_is_installed "terraform"
  print_ui_alb_table
}

run "$@"