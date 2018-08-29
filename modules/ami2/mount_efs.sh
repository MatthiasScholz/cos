#!/bin/bash
# A  script that mounts an EFS to /efs

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

function usage {
  echo "-------------------------------------------------------------------------------"
  echo "$SCRIPT_NAME -- A script that mounts an EFS to /efs"
  echo "-------------------------------------------------------------------------------"
  echo -e "call:"
  echo -e "\t$SCRIPT_NAME [optional <efs_mount_target>]"
  echo -e "optional parameters:"
  echo -e "\tefs_mount_target ... The DNS name of the EFS mount, default: ${EFS_DNS_NAME}"
  echo -e "example:"
  echo -e "\t$SCRIPT_NAME fs-f604d78f.efs.us-east-2.amazonaws.com"
}

function mount_efs {
  local readonly efs_mount_target=$1

  set -x
  if [ ! -d "/efs" ];
  then
    sudo mkdir -p /efs;
  else
    log_info "efs folder already exists"
  fi

  if df "/efs" | grep -q $efs_mount_target
  then
    log_info "efs already mounted"
  else
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $efs_mount_target:/ /efs

    if grep -q $efs_mount_target /etc/fstab
    then
      log_info "mountpoint already in /etc/fstab"
    else
      sudo echo -e "$efs_mount_target:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev,noresvport 0 0" | sudo tee --append /etc/fstab
    fi
  fi


  cd /efs
  sudo mkdir -p /efs/map/$map_name
  set +x
}


function run {
  local efs_mount_target=$1

  if [ -z "$efs_mount_target" ];
  then
    efs_mount_target="${EFS_DNS_NAME}"
  fi

  mount_efs $efs_mount_target

}

run "$@"