#!/bin/sh
set -e

# Environment variables are set by packer

echo "[INFO] [${SCRIPT}] Setup nomad ${NOMAD_VERSION}"
/tmp/install-nomad/install-nomad --version "${NOMAD_VERSION}"


echo "[INFO] [${SCRIPT}] Setup consul ${CONSUL_VERSION}"
readonly CONSUL_DL_ARTIFACT="/tmp/terraform-aws-consul"
git clone --branch "${CONSUL_MODULE_VERSION}"  https://github.com/hashicorp/terraform-aws-consul.git "${CONSUL_DL_ARTIFACT}"
"${CONSUL_DL_ARTIFACT}"/modules/install-consul/install-consul --version "${CONSUL_VERSION}"


# TODO This can be refactored to use systemd resolved service - this will avoid pulling additional packages, check terraform-aws-consul module for further background, maybe it is even obsolete.
# Activate Consul DNS Forwarding
# .The consul configuration file was injected in the packer configuration before.
sudo yum install -y dnsmasq
sudo systemctl enable dnsmasq
sudo mv /tmp/dnsmasq_10-consul.conf /etc/dnsmasq.d/10-consul
