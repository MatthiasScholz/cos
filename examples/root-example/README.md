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

Now you can either configure your shell using the bootstrap.sh script by calling:

```bash
source ./bootstrap.sh
```

Or you follow the preceding instructions.

## Setup helper scripts

```bash
script_dir=$(pwd)/../helper && export PATH=$PATH:$script_dir &&\
export AWS_PROFILE=playground
```

## Nomad

### Configure and check nomad

```bash
# Set the NOMAD_ADDR env variable
nomad_dns=$(terraform output nomad_ui_alb_dns) &&\
export NOMAD_ADDR=http://$nomad_dns &&\
echo ${NOMAD_ADDR}
```

### Wait until the nomad nodes are available

```bash
# wait for servers and clients
wait_for_servers.sh &&\
wait_for_clients.sh
```

### (Optional) Show some commands

```bash
nomad-examples-helper.sh
```

## Consul

### (Optional) Configure and check consul

```bash
# Set the CONSUL_HTTP_ADDR env variable
consul_dns=$(terraform output consul_ui_alb_dns) &&\
export CONSUL_HTTP_ADDR=http://$consul_dns &&\
echo ${CONSUL_HTTP_ADDR}
```

### (Optional) Wait until the consul nodes are available

```bash
# wait for servers and clients
## TBD
```

### (Optional) Watch for services to be registered at consul

```bash
# watch ping-service
watch -x consul watch -service=ping-service -type=service

# watch fabio
watch -x consul watch -service=fabio -type=service
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
# call the service over loadbalancer
ingress_alb_dns=$(terraform output ingress_alb_dns) &&\
watch -x curl -s http://$ingress_alb_dns/ping
```

## Destroy the infrastructure

```bash
# terraform destroy -var deploy_profile=<your-profile>

# on playground
terraform destroy -var deploy_profile=playground
```

## (Optional) Enable SSH access to instances

Connect to the bastion using sshuttle

```bash
# call
sshuttle_login.sh
```

## Architecture

### Network Setup

![Nomad architecture root-example](https://raw.githubusercontent.com/MatthiasScholz/cos/master/_docs/architecture-root-example.png)

### Datacenter Configuration

- [ ] TODO: Describe to configuration of the different nomad datacenters.

## Troubleshooting

### No images found for AMI

```bash
module.nomad-infra.module.dc-backoffice.module.data_center.aws_launch_configuration.launch_configuration: 1 error occurred:
aws_launch_configuration.launch_configuration: No images found for AMI ami-02d24827dece83bef
```

### MalformedCertificate: Certificate is no longer valid

If the used certificate is not valid any more you will receive the following (or similar) error.

```bash
aws_iam_server_certificate.certificate_alb: 1 error occurred:
aws_iam_server_certificate.certificate_alb: Error uploading server certificate, error: MalformedCertificate: Certificate is no longer valid. The 'Not After' date restriction on the certificate has passed.
```

To solve this issue a new certificate has to be created.

#### Create the self signed Certificate

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

Then copy the content of `cert.pem` into the field `certificate_body` of the file `alb_cert.tf`.
And copy the content of `key.pem` into the field `private_key` of the file `alb_cert.tf`.


## Remarks

### Simplified AMI Usage

This example uses the same AMI for the nomad servers, clients and the consul servers.
