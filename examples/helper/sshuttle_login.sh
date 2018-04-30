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

function gen_sshuttle_login {
  local readonly bastion_ip=$1
  local readonly vpc_cidr_block=$2
  local readonly ssh_key_name=$3

  echo "sshuttle -v -r ec2-user@"$bastion_ip" \
   -e 'ssh -v -o StrictHostKeyChecking=false -i "$ssh_key_name"' \
   -H "$vpc_cidr_block""
}

function print_usage {
  echo "$SCRIPT_NAME:"
  echo -e "\t-i,--bastion-ip:\t\tThe ip of the bastion-host."
  echo -e "\t-c,--cidr-vpc:\t\tCIDR of the vpc."
  echo -e "\t-k,--key:\t\tThe key-file to log into the bastion-instance."
  echo -e "\n"
  echo -e "\texample: $SCRIPT_NAME --bastion-ip 18.208.27.78 --cidr-vpc 10.128.0.0/16 --key ~/.ssh/kp-us-east-1-playground-instancekey.pem"
}

function run {
  assert_is_installed "sshuttle"
  assert_is_installed "getopt"

  ########## Parse Arguments ###########################################################
  OPTIONS=i:c:k:h
  LONGOPTIONS=bastion-ip:,cidr-vpc:,key:,help

  # -temporarily store output to be able to check for errors
  # -e.g. use “--options” parameter by name to activate quoting/enhanced mode
  # -pass arguments only via   -- "$@"   to separate them correctly
  PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
  if [[ $? -ne 0 ]]; then
      # e.g. $? == 1
      #  then getopt has complained about wrong arguments to stdout
      exit 2
  fi
  # read getopt’s output this way to handle the quoting right:
  eval set -- "$PARSED"

  bastion_ip=""
  cidr_vpc=""
  key=""
  print_help=false
  while true; do
      case "$1" in
          -i|--bastion-ip)
              bastion_ip="$2"
              shift 2
              ;;
          -c|--cidr-vpc)
              cidr_vpc="$2"
              shift 2
              ;;
          -k|--key)
              key="$2"
              shift 2
              ;;
          -h|--help)
              print_help=true
              shift
              ;;
          --)
              shift
              break
              ;;
          *)
              echo "Programming error"
              exit 3
              ;;
      esac
  done

  if [ "$print_help" = true ];then
    print_usage
    exit 0
  fi

  if [ -z "$bastion_ip" ];then
    echo "Parameter bastion-ip is missing."
    print_usage
    exit 1
  fi

  if [ -z "$cidr_vpc" ];then
    echo "Parameter cidr-vpc is missing."
    print_usage
    exit 1
  fi

  if [ -z "$key" ];then
    echo "Parameter key is missing."
    print_usage
    exit 1
  fi

  cmd=$(gen_sshuttle_login "$bastion_ip" "$cidr_vpc" "$key")
  echo "calling $cmd"
  eval $cmd
}

run "$@"