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
  shift
  local readonly message=("$@")
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  if [ "$VERBOSE_LOGGING" = true ];then
    >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message[@]}"
  fi
}

function log_info {
  local readonly message=("$@")
  log "INFO" "${message[@]}"
}

# Brief: Returns the ip-ranges (ipv4) for the given service type based on the given file.
# parameters: 
# 1 - name of the file
# 2 - aws region
# 3 - aws service-type
# example: ec2_ips=$(get_ips "$file" "$region" "EC2")
function get_ips {
  local readonly file=$1
  local readonly region=$2
  local readonly service=$3

  local readonly ips=$(cat $file | jq  ".prefixes[] | select(.region==\"$region\") | select(.service==\"$service\") | .ip_prefix")

  echo $ips
}

# Brief: Substracts the EC2 from the AMAZON ipv4 ip-ranges.
# parameters: 
# 1 - the EC2 ip's
# 2 - the AMAZON ip's
# example: ips=($(substract_amazon_and_ec2_cidr_blocks "$ec2_ips" "$amazon_ips"))
function substract_amazon_and_ec2_cidr_blocks {
  local readonly ec2_ips=($1)
  local readonly amazon_ips=($2)

  ips=()
  for aip in ${amazon_ips[@]}
  do  
    isAnEC2Ip=false
    for eip in ${ec2_ips[@]}
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

  echo "${ips[@]}"
}


# Brief: Merges the two given lists of cird_blocks to one.
# parameters: 
# 1 - first list of cidr-blocks
# 2 - second list of cidr-blocks
# example: ips=($(merge_cidr_block_lists "$ec2_ips" "$amazon_ips"))
function merge_cidr_block_lists {
  local readonly cidr_list1=($1)
  local readonly cidr_list2=($2)

  merged_cidr_blocks=()
  for cidr in ${cidr_list1[@]}
  do  
    merged_cidr_blocks+=("$cidr")
  done

  for cidr in ${cidr_list2[@]}
  do  
    merged_cidr_blocks+=("$cidr")
  done
  
  echo "${merged_cidr_blocks[@]}"
}


# Brief: Takes the list of ip's and generates /8 cidr-blocks out of it
# parameters: 
# 1 - the ip's
# example: cidr_blocks=$(to_cidr_block_8 "${ips[@]}")
function to_cidr_block_8 { 
  ips=($1)
  
  cidr_blocks=()
  for ip in ${ips[@]}
  do
    # strip the "" from the ip
    # i.e. "205.251.240.0/22" -> 205.251.240.0/22
    clean_ip=${ip//\"/}

    # extract the maskbits
    ip_arr=(${clean_ip//\// })
    masked_part=${ip_arr[1]}

    if (( $masked_part < 8 )); then
      cidr_blocks+=($clean_ip)
      log_info "full ip: $clean_ip"
    else
      # splti into parts of the ip
      # 10.102.23.45 --> [10 102 23 45]
      ip_parts=(${ip_arr[0]//./ })

      # generate a /16 mask
      #ip_prefix="${ip_parts[0]}.${ip_parts[1]}"
      ip_prefix="${ip_parts[0]}.0"
      widened_ip="$ip_prefix.0.0/8"
      
      log_info "too narrow ip: $ip --> $widened_ip"
      cidr_blocks+=($widened_ip)
    fi
  done

  echo ${cidr_blocks[@]}
}


# Brief: Removes duplicate entries in the given list of cidr-blocks.
# parameters: 
# 1 - the cidr_blocks
# example: unique_cidr_blocks=$(remove_duplicates "${cidr_blocks[@]}")
function remove_duplicates {
  cidrs=($1)

  # remove duplicates
  unique_cidrs=()
  for cidr in ${cidrs[@]}
  do
    isDuplicate=false
    for unique_cidr in ${unique_cidrs[@]}
    do
      if [ "$unique_cidr" = "$cidr"  ];then
        log_info "Remove duplicate: $unique_cidr"
        isDuplicate=true
        break
      fi
    done
    
    if [ "$isDuplicate" = false ];then
      unique_cidrs+=("$cidr")
      log_info "Add $cidr"
    fi  
  done

  echo ${unique_cidrs[@]}
}


# Brief: Generates an terraform variable having the specfied AWS ip-ranges.
# parameters: 
# 1 - the ip's
# 2 - the region
# example: tf_var=$(generate_tf_variable "${ips[*]}" "$region")
function generate_tf_variable {
  
  local readonly ips=($1)
  local readonly region=$2

  local out="variable \"aws_ip_address_ranges\" {\n"
  out+="\tdescription \t= \"List of ip-ranges for accessing aws services (S3, EC2, ElastiCache, ..) in $region see: http://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html\"\n"
  out+="\ttype        \t\t= \"list\"\n"
  out+="\tdefault     \t= ["

  local readonly num_elements="${#ips[@]}"
  idx=0
  for ip in ${ips[@]}
  do
    out+="\"$ip\""
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
cloud_front_ips=$(get_ips "$file" "$region" "CLOUDFRONT")

merged_cidrs=$(merge_cidr_block_lists "${ec2_ips[@]}" "${amazon_ips[@]}")
merged_cidrs=$(merge_cidr_block_lists "${merged_cidrs[@]}" "${cloud_front_ips[@]}")

# merge both ranges (AMAZON minus EC2)
#ips=$(substract_amazon_and_ec2_cidr_blocks "$ec2_ips" "$amazon_ips")

cidr_8=$(to_cidr_block_8 "${merged_cidrs[@]}")

unique_cidr_8=$(remove_duplicates "${cidr_8[@]}")

# Print the tf-variable
echo -e $(generate_tf_variable "${unique_cidr_8[@]}" "$region")
