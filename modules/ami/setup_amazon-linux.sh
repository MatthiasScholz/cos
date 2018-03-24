#!/bin/sh
set -e

SCRIPT=`basename "$0"`

echo "[INFO] [${SCRIPT}] Setup git"
sudo yum install -y git

echo "[INFO] [${SCRIPT}] Setup docker"
# There is a bug in docker version: 17.12.0ce-1.129.amzn1
# Regarding privileged container handling:
# .https://github.com/docker/for-linux/issues/219
sudo yum install -y docker-17.09.1ce-1.111.amzn1.x86_64
sudo service docker start
sudo usermod -a -G docker ec2-user
