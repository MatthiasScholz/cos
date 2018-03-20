# Overview

Basic example for the module.
Per default the module will be deployed in us-east-1 (virginia).

## Deploy the infrastructure

```bash
# terraform init &&\
# terraform plan -out file.plan -var deploy_profile=<your-profile> &&\
# terraform apply "file.plan"

# on playground
terraform init &&\
terraform plan -out file.plan -var deploy_profile=playground &&\
terraform apply "file.plan"
```

## Setup helper scripts

```bash
script_dir=$(pwd)/../helper && export PATH=$PATH:$script_dir &&\
export AWS_PROFILE=playground
```

## Configure and check nomad

```bash
# Wait for the servers getting ready and set the NOMAD_ADDR env variable
server_ip=$(get_nomad_server_ip.sh) &&\
export NOMAD_ADDR=http://$server_ip:4646

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

## Test the service

```bash
# 1. find the ip of one instance
instance_ip=$(get_nomad_client_info.sh | awk '!/INSTANCE/{print $1}' | head -n 1)

# call the service
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
