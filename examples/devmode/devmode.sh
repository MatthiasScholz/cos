#!/bin/bash

set -o errexit

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

function checkIp {
  local readonly ipAddr=$1

  set +o errexit  
  matchResult=$(echo "${ipAddr}" | grep "^[0-9]\{0,3\}\.[0-9]\{0,3\}\.[0-9]\{0,3\}\.[0-9]\{0,3\}$")
  set -o errexit

  if [ "$matchResult" != "$ipAddr" ]; then
    log_error "Given ipAddr=${ipAddr} is not valid ${matchResult}"
    exit 1
  fi
}

function printUsage {
  echo "Usage: ${SCRIPT_NAME} <hostIpAddr>"
  echo -e "\thostIpAddr ... ip address of your host that should be used to communicate instead of localhost."
}

function copy_files {
  tempDir=$(mktemp -d)
  log_info "Copy the configuration files to ${tempDir}"

  cp -R ../devmode ${tempDir}
  echo "${tempDir}/devmode"
}

function replaceTemplateVarInFiles {
  local readonly workingDir=$1
  local readonly templateToReplace=$2
  local readonly value=$3

  files=(consul.hcl registry/creg.nomad nomad.hcl fabio_docker.nomad)

  for item in ${files[*]}
  do
    file=${workingDir}/${item}
    log_info "Replacing ${templateToReplace} by ${value} in ${file}."
    command="sed -i.bak s/${templateToReplace}/${value}/g ${file}"
    #log_info "\tCalling ${command}"
    eval ${command}
  done
}

function run {
  assert_is_installed "nomad"
  assert_is_installed "consul"

  local readonly dataCenterDefault="testing"
 
  local readonly ipAddr=$1
  local readonly datacenter=$2


  if [[ -z "$ipAddr" ]]; then
    log_error "Parameter IpAddr is missing."
    printUsage
    exit 1
  fi

  if [[ -z "$datacenter" ]]; then
    log_error "Parameter datacenter is missing using the default value '${dataCenterDefault}' instead."
    datacenter=${dataCenterDefault}
  fi

  # check if the given parameter is a valid ip address
  checkIp "${ipAddr}"

  # copy the files into a temporary file in order to be able to replace template variables
  workingDir=$(copy_files)

  replaceTemplateVarInFiles "${workingDir}" "{{host_ip_address}}" "${ipAddr}"
  replaceTemplateVarInFiles "${workingDir}" "{{datacenter}}" "${datacenter}"

  

}

run "$@"