#!/bin/sh
set -e

SCRIPT=`basename "$0"`

echo "[INFO] [${SCRIPT}] Testing the Nomad Cluster"
server_ip=$(get_nomad_server_ip.sh) &&          \
    export NOMAD_ADDR=http://$server_ip:4646 && \
    echo ${NOMAD_ADDR}

echo "[INFO] [${SCRIPT}] Waiting for the servers to find each other"
nomad-examples-helper.sh

echo "[INFO] [${SCRIPT}] Current state jobs"
nomad status
echo "[INFO] [${SCRIPT}] Current state server"
nomad server-members
echo "[INFO] [${SCRIPT}] Current state nodes"
nomad node-status
