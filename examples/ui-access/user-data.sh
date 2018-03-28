#!/bin/bash

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

mkdir -p nomad/ui

cat > nomad/ui/jobs <<EOF
<h1>Nomad UI</h1>
EOF

cd nomad
nohup busybox httpd -f -p ${nomad_ui_port} &


cd ..
mkdir -p consul/ui
cd  consul

cat > ui/index.html <<EOF
<h1>Consul UI</h1>
EOF

nohup busybox httpd -f -p ${consul_ui_port} &
