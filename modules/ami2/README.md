# Overview

This documents provides some help on how to use 
pre-configured Amazon Machine Image descriptions to create a nomad cluster.

## Amazon Linux 2

https://aws.amazon.com/de/amazon-linux-2/release-notes/

Certain flavors with different supported functionalities are supported.

### AMI without ECR support

The packer definition `nomad-consul-docker.json` creates an ami that can load docker images from public repositories such as docker hub.

- Nomad
- Consul
- Docker
- privileged mode activated

### AMI with ECR support

The packer definition `nomad-consul-docker-ecr.json` creates an ami with ECR support. That means you can load docker images hosted at a AWS ECR of your account.

- Nomad
- Consul
- Docker
- privileged mode activated
- AWS ECR plugin

## Create the Amazon Machine Image

### Prepare 

#### AWS Credentials

As described at [Authentication Packer](https://www.packer.io/docs/builders/amazon.html#authentication) you can use static, environment variables or shared credentials.

```bash
# environment variables
export AWS_ACCESS_KEY_ID=<your access key id>
export AWS_SECRET_ACCESS_KEY=<your secret key>
export AWS_DEFAULT_REGION=us-east-1
```

#### Goss Provisioner

The packer builds are verified during the build process using [goss](https://goss.rocks/).
Goss needs to be available as provisioner for packer to build AMIs.

```bash
# Install goss provisioner
make prepare
```

### Build

The following can be applied for `nomad-consul-docker-ecr.json` and `nomad-consul-docker.json`.

```bash
# Build the AMI using the AWS_DEFAULT_REGION
make ami

# If the AMI should be available in multiple regions
make ami additional_aws_regions="us-east-1,us-east-2"
```

#### Packer Details

Under the hood AMI are created using [packer](https://packer.io), please find below more sophisticated examples.

```bash
# Build it using the default variables specified in the packer file.
# Important variables are:
# aws_region - The region where the ami is build in. The exported account settings have to match to this region.
# ami_regions - A list (comma separated) of regions this ami should be available in as well (will be copied over).
# aws_account_ids - A list of AWS account Id's (comma separated list) this ami should be allowed to used from.
packer build nomad-consul-docker-ecr.json

# Build the AMI in us-east-1 and make it available in us-east-2 as well.
packer build -var 'aws_region=us-east-1' -var 'ami_regions=us-east-1,us-east-2' nomad-consul-docker-ecr.json

# Build the AMI in us-east-1, make it available in us-east-2 as well and grant access from account 123456789 and 987654321.
packer build -var 'aws_region=us-east-1' -var 'ami_regions=us-east-1,us-east-2' -var aws_account_ids='123456789,987654321' nomad-consul-docker-ecr.json
```
