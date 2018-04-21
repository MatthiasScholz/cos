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

## Test

This example has one curl example output for each of the ALB's to access the ui. To test you just have to call it.

I.e. the output for nomad ui was ```curl_nomad_ui = curl http://alb-nomad-ui-example-1440612083.us-east-1.elb.amazonaws.com/ui/jobs```, then the call should return ```<h1>Nomad UI</h1>```.

## Destroy the infrastructure

```bash
# terraform destroy -var deploy_profile=<your-profile>

# on playground
terraform destroy -var deploy_profile=playground
```