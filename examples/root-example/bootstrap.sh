#!/bin/sh

SCRIPT=`basename "$0"`

echo "[INFO] [${SCRIPT}] Add helper scripts to PATH and set playground as AWS_PROFILE"
script_dir=$(pwd)/../helper
export PATH=$PATH:$script_dir
export AWS_PROFILE=playground

echo "[INFO] [${SCRIPT}] Confiugure NOMAD_ADDR"
nomad_dns=$(terraform output nomad_ui_alb_dns)
export NOMAD_ADDR=http://$nomad_dns
echo ${NOMAD_ADDR}

echo "[INFO] [${SCRIPT}] Wait until nomad servers are available and a leader is elected."
wait_for_servers.sh

echo "\n[INFO] [${SCRIPT}] ############# Nomad servers: ################################"
nomad server members

echo "[INFO] [${SCRIPT}] Wait until nomad clients are available."
wait_for_clients.sh

echo "\n[INFO] [${SCRIPT}] ############# Nomad clients: ################################"
nomad node status

echo "[INFO] [${SCRIPT}] Confiugure CONSUL_HTTP_ADDR"
consul_dns=$(terraform output consul_ui_alb_dns)
export CONSUL_HTTP_ADDR=http://$consul_dns
echo ${CONSUL_HTTP_ADDR}

echo "\n[INFO] [${SCRIPT}] ############# Consul members: ################################"
consul members

echo "[INFO] [${SCRIPT}] Set the job-dir."
export JOB_DIR=$(pwd)/../jobs
echo "$JOB_DIR"

echo "[INFO] [${SCRIPT}] Useful commands:"
# deploy fabio
echo '\tDeploy fabio: nomad run $JOB_DIR/fabio.nomad'

# deploy ping_service
echo '\tDeploy ping_service: nomad run $JOB_DIR/ping_service.nomad'

# Testing the service
export IG_ALB_DNS=$(terraform output ingress_alb_dns)
echo '\tTest the service: watch -x curl -s http://$IG_ALB_DNS/ping'

# Open the UI's.
echo '\tOpen consul ui: xdg-open $CONSUL_HTTP_ADDR'
echo '\tOpen nomad ui: xdg-open $NOMAD_ADDR'
export FABIO_ADDR="$(get_ui_albs.sh | awk '/fabio/ {print $3}')"
echo '\tOpen fabio ui: xdg-open $FABIO_ADDR'
