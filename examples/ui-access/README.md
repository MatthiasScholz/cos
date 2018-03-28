# Overview

Basic example for the ui-access module.
Per default the module will be deployed in us-east-1 (virginia).

## Deploy the infrastructure

```bash
# terraform init &&\
# terraform plan -out ui.plan -var deploy_profile=<your-profile> &&\
# terraform apply "ui.plan"

# on playground
terraform init &&\
terraform plan -out ui.plan -var deploy_profile=playground &&\
terraform apply "ui.plan"
```

## Destroy the infrastructure

```bash
# terraform destroy -var deploy_profile=<your-profile>

# on playground
terraform destroy -var deploy_profile=playground
```