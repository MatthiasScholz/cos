# Overview

Basic example for the module.
Per default the module will be deployed in us-east-1 (virginia).

## Run the example

```bash
# terraform init &&\
# terraform plan -out file.plan -var deploy_profile=<your-profile> &&\
# terraform apply "file.plan"

# on playground
terraform init &&\
terraform plan -out file.plan -var deploy_profile=playground &&\
terraform apply "file.plan"
```

## Clean up

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
