#!/bin/bash
# A script that copies a map from S3 to EFS

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
  echo "$SCRIPT_NAME -- A script that copies a map from S3 to EFS"
  echo "-------------------------------------------------------------------------------"
  echo -e "call:"
  echo -e "\t$SCRIPT_NAME <map_name> <tmap_zip_folder> [optional <efs_mount_target> <s3_bucket>]"
  echo -e "parameters:"
  echo -e "\tmap_name ... The name of the map (i.e. EUR_18CW30_Sprint52)"
  echo -e "\tmap_zip_folder ... The name of the Folder containing the ROOT.NDS which usually ends in .zip (i.e.EUR_1CS052_FCT3WS-18118_FULLMAP.zip)"
  echo -e "optional parameters"
  echo -e "\tefs_mount_target ... The DNS name of the EFS mount target where to copy the map to, default: ${efs_dns}"
  echo -e "\ts3_bucket ... The name of the S3-Bucket where the map is located, default: ${map_bucket}"
  echo -e "example:"
  echo -e "\t$SCRIPT_NAME EUR_18CW30_Sprint52 EUR_1CS052_FCT3WS-18118_FULLMAP.zip fs-f604d78f.efs.us-east-2.amazonaws.com"
}

function check_params {
  local readonly map_name=$1
  local readonly map_zip_folder=$2
  local readonly efs_mount_target=$3
  local readonly s3_bucket=$4


  if [ -z "$map_name" ];
  then
    log_error "Parameter 'map_name' is missing"
    usage $SCRIPT_NAME
    exit 1
  fi

  if [ -z "$s3_bucket" ];
  then
    log_error "Parameter 's3_bucket' is missing"
    usage $SCRIPT_NAME
    exit 1
  fi

  if [ -z "$map_zip_folder" ];
  then
    log_error "Parameter 'map_zip_folder' is missing"
    usage $SCRIPT_NAME
    exit 1
  fi

  if [ -z "$efs_mount_target" ];
  then
    log_error "Parameter 'efs_mount_target' is missing"
    usage $SCRIPT_NAME
    exit 1
  fi
}

function mount_efs {
  local readonly efs_mount_target=$1

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

}

function copy_map {
  local readonly map_name=$1
  local readonly s3_bucket=$2
  local readonly map_zip_folder=$3

  cd /efs
  sudo mkdir -p /efs/map/$map_name
  sudo aws s3 sync s3://$s3_bucket/maps/maps/$map_name/$map_zip_folder/ /efs/map/$map_name
  sudo aws s3 sync s3://$s3_bucket/maps/versions/$map_name/ /efs/map/$map_name

}

function run {
  assert_is_installed "aws"

  local readonly map_name=$1
  local readonly map_zip_folder=$2
  local efs_mount_target="${efs_dns}"
  local s3_bucket="${map_bucket}"

  if [ "$#" -eq 3 ]; then
    log_info "testing what the third argument is"
    if [[ $3 = *"mdrs"* ]]; then
      s3_bucket=$3
    else
      efs_mount_target=$3
    fi
  fi

  if [ "$#" -eq 4 ]; then
      s3_bucket=$3
      efs_mount_target=$4
  fi

  check_params $map_name $map_zip_folder $efs_mount_target $s3_bucket

  mount_efs $efs_mount_target

  copy_map $map_name $s3_bucket $map_zip_folder
}

run "$@"
