#!/bin/sh
set -e

# Environment variables are set by packer
/tmp/install-nomad/install-nomad --version "${NOMAD_VERSION}"

# FIXME: Removed supervisord usage from consul as well
# FIXME: This is so ugly! Why not catching the binaries directly?
# FIXME: Removed supervisord usage from consul as well
git clone --branch "${CONSUL_MODULE_VERSION}"  https://github.com/hashicorp/terraform-aws-consul.git /tmp/terraform-aws-consul
/tmp/terraform-aws-consul/modules/install-consul/install-consul --version "${CONSUL_VERSION}"

# Activate Consul DNS Forwarding
# .The consul configuration file was injected in the packer configuration before.
sudo yum install -y dnsmasq
sudo systemctl enable dnsmasq
sudo mv /tmp/dnsmasq_10-consul.conf /etc/dnsmasq.d/10-consul
