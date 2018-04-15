# Overview

Basic example for the bastion module.
Per default the module will be deployed in us-east-1 (virginia) into three AZ's.

## Deploy the infrastructure

```bash
# terraform init &&\
# terraform plan -out bst.plan -var deploy_profile=<your-profile> &&\
# terraform apply "bst.plan"

# on playground
terraform init &&\
terraform plan -out bst.plan -var deploy_profile=playground &&\
terraform apply "bst.plan"
```

## Test

Just call the output of the example called ```ssh_login```.

```bash
# example
ssh ec2-user@35.170.62.37 -i ~/.ssh/kp-us-east-1-playground-instancekey.pem
```


## Destroy the infrastructure

```bash
# terraform destroy -var deploy_profile=<your-profile>

# on playground
terraform destroy -var deploy_profile=playground
```