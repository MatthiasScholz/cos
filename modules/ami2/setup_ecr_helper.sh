#!/bin/sh
set -e

SCRIPT=`basename "$0"`

echo "[INFO] [${SCRIPT}] Setup Docker ECR login"
sudo systemctl start docker

echo "[INFO] [${SCRIPT}] .Build"
git clone https://github.com/awslabs/amazon-ecr-credential-helper.git /tmp/ecr_helper
cd /tmp/ecr_helper
sudo make docker

echo "[INFO] [${SCRIPT}] .Install"
sudo cp bin/local/docker-credential-ecr-login /usr/bin

echo "[INFO] [${SCRIPT}] .Cleanup"
cd /tmp/
sudo rm -rf ecr_helper
