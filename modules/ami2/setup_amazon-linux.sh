#!/bin/sh
set -e

SCRIPT=`basename "$0"`

echo "[INFO] [${SCRIPT}] Setup git"
sudo yum install -y git

echo "[INFO] [${SCRIPT}] Setup docker"
sudo amazon-linux-extras install docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

echo "[INFO] [${SCRIPT}] Setup time synchronisation"
sudo systemctl enable chronyd
sudo systemctl status chronyd

echo "[INFO] [${SCRIPT}] Cleanup packages"
sudo yum remove -y powershell

