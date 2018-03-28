# Overview

Basic example for the consul module.
Per default the module will be deployed in us-east-1 (virginia) into three AZ's.

## Deploy the infrastructure

```bash
# terraform init &&\
# terraform plan -out consul.plan -var deploy_profile=<your-profile> &&\
# terraform apply "consul.plan"

# on playground
terraform init &&\
terraform plan -out consul.plan -var deploy_profile=playground &&\
terraform apply "consul.plan"
```

## Destroy the infrastructure

```bash
# terraform destroy -var deploy_profile=<your-profile>

# on playground
terraform destroy -var deploy_profile=playground
```