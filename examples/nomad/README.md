# Overview

Basic example for the nomad module.
Per default the module will be deployed in us-east-1 (virginia) into three AZ's. Additionally to ensure that the nomad servers find each other the consul-server module is also deployed with this example.

## Deploy the infrastructure

```bash
# terraform init &&\
# terraform plan -out nm.plan -var deploy_profile=<your-profile> &&\
# terraform apply "nm.plan"

# on playground
terraform init &&\
terraform plan -out nm.plan -var deploy_profile=playground &&\
terraform apply "nm.plan"
```

## Test

### Setup helper scripts

```bash
script_dir=$(pwd)/../helper && export PATH=$PATH:$script_dir &&\
export AWS_PROFILE=playground
```

### Run the test script

```bash
./run_test.sh
```

The result should look like this:

```none
Your Nomad servers are running at the following IP addresses:

    107.23.12.65
    35.170.70.70
    54.85.220.0

Some commands for you to try:

Configure ip of nomad-server:   export NOMAD_ADDR=http://107.23.12.65:4646
Open nomad ui:                  nomad ui
Watch servers:                  watch -x nomad server-members
Watch nodes:                    watch -x nomad node-status
Deploy fabio-loadbalancer:      nomad run /home/winnietom/work/projects/cos/Nomad/cos/examples/helper/fabio.nomad
Deploy ping_service:            nomad run /home/winnietom/work/projects/cos/Nomad/cos/examples/helper/ping_service.nomad
Remove ping_service:            nomad stop ping_service
Watch status of ping_service:   watch -x nomad status ping_service

[INFO] [run_tests.sh] Current state jobs
No running jobs
[INFO] [run_tests.sh] Current state server
Name                           Address        Port  Status  Leader  Protocol  Build  Datacenter  Region
i-02c89e17768005473.us-east-1  172.31.67.3    4648  alive   false   2         0.7.1  leader      us-east-1
i-0484b34c74263abcf.us-east-1  172.31.15.184  4648  alive   false   2         0.7.1  leader      us-east-1
i-06b5b3f07b60b8745.us-east-1  172.31.49.121  4648  alive   true    2         0.7.1  leader      us-east-1
[INFO] [run_tests.sh] Current state nodes
```

## Destroy the infrastructure

```bash
# terraform destroy -var deploy_profile=<your-profile>

# on playground
terraform destroy -var deploy_profile=playground
```