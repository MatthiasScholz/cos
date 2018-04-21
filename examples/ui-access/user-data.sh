#!/bin/bash

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

### Health endpoint for nomad
mkdir -p nomad/ui

cat > nomad/ui/jobs <<EOF
<h1>Nomad UI</h1>
EOF

cd nomad
nohup busybox httpd -f -p ${nomad_ui_port} &

### Health endpoint for consul
cd ..
mkdir -p consul/v1/status/
cd  consul

cat > v1/status/leader <<EOF
<h1>Consul UI</h1>
EOF

nohup busybox httpd -f -p ${consul_ui_port} &

### Health endpoint for fabio
cd ..
mkdir -p fabio
cd  fabio

cat > health <<EOF
<h1>Fabio UI</h1>
EOF

nohup busybox httpd -f -p ${fabio_ui_port} &