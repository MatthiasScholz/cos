#!/bin/sh
set -e

SCRIPT=`basename "$0"`

echo "[INFO] [${SCRIPT}] Testing the Nomad Cluster"
server_ip=$(get_nomad_server_ip.sh) &&          \
    export NOMAD_ADDR=http://$server_ip:4646 && \
    echo ${NOMAD_ADDR}

echo "[INFO] [${SCRIPT}] Current state jobs"
nomad status
echo "[INFO] [${SCRIPT}] Current state server"
nomad server-members
echo "[INFO] [${SCRIPT}] Current state nodes"
nomad node-status

echo "[INFO] [${SCRIPT}] Deploying some jobs"
nomad run ../jobs/fabio.nomad
nomad run ../jobs/ping_service.nomad
nomad run ../jobs/cicd.nomad

sleep 5

echo "[INFO] [${SCRIPT}] Current state jobs"
nomad status
