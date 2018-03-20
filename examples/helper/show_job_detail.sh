#!/bin/bash

job_name=$1

if [ -z "$job_name" ];then
  echo "Parameter missing."
  echo -e "\tUsage: show_job_detail.sh <job-name>"
  exit 1
fi 

echo "Status of $job_name..."

nomad status $(nomad status $job_name | grep ago | head -n 1 | awk '{print $1}')