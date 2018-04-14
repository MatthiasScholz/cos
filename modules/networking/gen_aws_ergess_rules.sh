#!/bin/bash

set -e

# https://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html
# As stated there under Implementing Egress Control:
# "To allow an instance to access only AWS services, create a security group with rules that allow outbound
# traffic to the CIDR blocks in the AMAZON list, minus the CIDR blocks that are also in the EC2 list."

readonly SCRIPT_NAME="$(basename "$0")"


function assert_is_installed {
  local readonly name="$1"

  if [[ ! $(command -v ${name}) ]]; then
    log_error "The binary '$name' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
}

function log {
  local readonly level="$1"
  local readonly message="$2"
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  if [ "$VERBOSE_LOGGING" = true ];then
    >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
  fi
}



function log_info {
  local readonly message="$1"
  log "INFO" "$message"
}

function get_ips {
  local readonly file=$1
  local readonly region=$2
  local readonly service=$3

  local readonly ips=$(cat $file | jq  ".prefixes[] | select(.region==\"$region\") | select(.service==\"$service\") | .ip_prefix")

  echo $ips
}

function merge_ipranges {
  local readonly ec2_ips=$1
  local readonly amazon_ips=$2  

  ips=()
  for aip in $amazon_ips
  do  
    isAnEC2Ip=false
    for eip in $ec2_ips
    do     
      if [ "$aip" = "$eip"  ];then
        isAnEC2Ip=true
        log_info "Remove duplicate: $eip==$aip"
        break
      fi  
    done
  
    if [ "$isAnEC2Ip" = false ];then
      ips+=("$aip")
      log_info "Add $aip"
    fi  
  done

  echo "${ips[*]}"
}

function generate_tf_variable {
  
  ips=$1
  region=$2

  out="variable \"aws_ip_address_ranges\" {\n"
  out+="\tdescription \t= \"List of ip-ranges for accessing aws services (S3, EC2, ElastiCache, ..) in $region see: http://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html\"\n"
  out+="\ttype        \t\t= \"list\"\n"
  out+="\tdefault     \t= ["

  num_elements="${#ips[*]}"
  idx=0
  for ip in $ips
  do
    out+=$ip
    ((idx++))

    if (( $idx < $num_elements ));then
      out+=","
    fi

  done
  out+="]\n"
  out+="}"
  
  echo $out 
}


function print_usage {
  echo "$SCRIPT_NAME:"
  echo -e "\t-v,--verbose:\t\tEnable verbose logging."
  echo -e "\t-f,--file:\t\tInputfile."
  echo -e "\t-r,--region:\t\tThe region."
  echo -e "\n"
  echo -e "\texample: $SCRIPT_NAME --file ip-ranges.json --region eu-central-1"
}

assert_is_installed "jq"
assert_is_installed "getopt"

########## Parse Arguments ###########################################################
OPTIONS=r:f:vh
LONGOPTIONS=region:,file:,verbose,help

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

file=""
region=""
VERBOSE_LOGGING=false
print_help=false
while true; do
    case "$1" in
        -r|--region)
            region="$2"
            shift 2
            ;;
        -f|--file)
            file="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE_LOGGING=true
            shift
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

if [ -z "$file" ];then
  echo "Parameter file is missing."
  print_usage
  exit 1
fi

if [ -z "$region" ];then
  echo "Parameter region is missing."
  print_usage
  exit 1
fi

########## Parse Arguments ###########################################################


if [ "$print_help" = true ];then
  print_usage
  exit 0
fi

# obtain the ec2 ip and the AMAZON ip-ranges
ec2_ips=$(get_ips "$file" "$region" "EC2")
amazon_ips=$(get_ips "$file" "$region" "AMAZON")

# merge both ranges (AMAZON minus EC2)
ips=($(merge_ipranges "$ec2_ips" "$amazon_ips"))

log_info "Num items: ${#ips[*]}"
log_info "Data: ${ips[*]}"

# Print the tf-variable
echo -e $(generate_tf_variable "${ips[*]}" "$region")
