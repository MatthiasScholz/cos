# Overview

- [ ] TODO: Explaining the available AMIs.

# Amazon Linux 2

https://aws.amazon.com/de/amazon-linux-2/release-notes/

- Nomad
- Consul
- Docker
- AWS ECR plugin
- privileged mode activated

## Create the Machine Image

### Prepare AWS Credentials

As described at [Authentication Packer](https://www.packer.io/docs/builders/amazon.html#authentication) you can use static, environment variables or shared credentials.

```bash
# environment variables
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-west-2"
```

### Build the AMI using Packer

```bash
# Build it using the default variables specified in the packer file.
# Important variables are:
# aws_region - The region where the ami is build in. The exported account settings have to match to this region.
# ami_regions - A list (comma separated) of regions this ami should be available in as well (will be copied over).
# aws_account_ids - A list of AWS account Id's (comma separated list) this ami should be allowed to used from.
packer build nomad-consul-docker-ecr.json

# Build the AMI in us-east-1 and make it available in us-east-2 as well.
packer build -var 'aws_region=us-east-1' -var 'ami_regions=us-east-1,us-east-2' nomad-consul-docker-ecr.json

# Build the AMI in us-east-1, make it available in us-east-2 as well and grant access from account 123456789 and 123456789.
packer build -var 'aws_region=us-east-1' -var 'ami_regions=us-east-1,us-east-2' -var aws_account_ids='123456789,123456789' nomad-consul-docker-ecr.json
```
