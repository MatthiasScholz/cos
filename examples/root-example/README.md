# Overview

Basic example for the module.
Per default the module will be deployed in us-east-1 (virginia).

## Deploy the infrastructure

```bash
# terraform init &&\
# terraform plan -out cos.plan -var deploy_profile=<your-profile> &&\
# terraform apply "cos.plan"

# on playground
terraform init &&\
terraform plan -out cos.plan -var deploy_profile=playground &&\
terraform apply "cos.plan"
```

## Setup helper scripts

```bash
script_dir=$(pwd)/../helper && export PATH=$PATH:$script_dir &&\
export AWS_PROFILE=playground
```

## Connect to the bastion using sshuttle

```bash
# call
sshuttle_login.sh
```

## Configure and check nomad

```bash
# Wait for the servers getting ready and set the NOMAD_ADDR env variable
server_ip=$(get_nomad_server_ip.sh) &&\
export NOMAD_ADDR=http://$server_ip:4646 &&\
echo ${NOMAD_ADDR}

# Show some commands
nomad-examples-helper.sh
```

## Deploy sample services

```bash
job_dir=$(pwd)/../jobs

# 1. Deploy fabio
nomad run $job_dir/fabio.nomad

# 2. Deploy ping_service
nomad run $job_dir/ping_service.nomad
```

## Open UI's

```bash
xdg-open $(get_ui_albs.sh | awk '/consul/ {print $3}') &&\
xdg-open $(get_ui_albs.sh | awk '/nomad/ {print $3}') &&\
xdg-open $(get_ui_albs.sh | awk '/fabio/ {print $3}')
```

## Test the service

```bash
# 1. find the ip of one instance
instance_ip=$(get_nomad_client_info.sh | awk '!/INSTANCE/{print $1}' | head -n 1)

# call the service over instance directly
watch -x curl -s http://$instance_ip:9999/ping

# call the service over loadbalancer
watch -x curl -s http://<name-of-loadbalancer>/ping
```

## Destroy the infrastructure

```bash
# terraform destroy -var deploy_profile=<your-profile>

# on playground
terraform destroy -var deploy_profile=playground
```

## Architecture

### Network Setup

![Nomad architecture root-example](https://raw.githubusercontent.com/MatthiasScholz/cos/master/_docs/architecture-root-example.png)

### Datacenter Configuration

* [ ] TODO: Describe to configuration of the different nomad datacenters.
