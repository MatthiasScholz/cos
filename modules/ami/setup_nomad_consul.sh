#!/bin/sh
set -e

# FIXME: Use install-nomad script from terraform-aws-nomad.git as basis - easier to stay up-to-date
# Environment variables are set by packer
# NOTE: Script will try to update all installed packages
/tmp/install-nomad/install-nomad --version "${NOMAD_VERSION}"

# NOTE: Consul will try to update all installed packages
git clone --branch "${CONSUL_MODULE_VERSION}"  https://github.com/hashicorp/terraform-aws-consul.git /tmp/terraform-aws-consul
/tmp/terraform-aws-consul/modules/install-consul/install-consul --version "${CONSUL_VERSION}"
