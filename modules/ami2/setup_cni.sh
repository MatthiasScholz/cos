#!/bin/sh
set -e

# Environment variables are set by packer

echo "[INFO] [${SCRIPT}] Setup CNI Plugins ${CNI_VERSION}"
readonly CNI_DL_ARTIFACT="/tmp/cni.tgz"
curl -L -o "${CNI_DL_ARTIFACT}" https://github.com/containernetworking/plugins/releases/download/v"${CNI_VERSION}"/cni-plugins-linux-amd64-v"${CNI_VERSION}".tgz

readonly CNI_INSTALL_PATH="/opt/cni/bin/"
sudo mkdir -p "${CNI_INSTALL_PATH}"
sudo tar -xvzf "${CNI_DL_ARTIFACT}" -C "${CNI_INSTALL_PATH}"
rm -rf "${CNI_DL_ARTIFACT}"
