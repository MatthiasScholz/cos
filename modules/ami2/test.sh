#!/bin/sh
set -e

# TODO Maybe try using goss

echo "[INFO] [${SCRIPT}] Test CNI installation"
ls -la /opt/cni/bin/bridge

# WORKING echo "[INFO] [${SCRIPT}] Test Google Docker Registry"
# WORKING sudo systemctl start docker
# WORKING sudo systemctl status docker
# WORKING sudo docker pull gcr.io/google-containers/pause-amd64:3.0
# WORKING 
# WORKING 
# WORKING ls -la fail
