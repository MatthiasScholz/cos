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

As described at [Authentication Packer](https://www.packer.io/docs/builders/amazon.html#authentication) you can use static, evironment variables or shared credentials.

```bash
# environment variables
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-west-2"
```

### Build the AMI using Packer

```bash
packer build nomad-consul-docker-ecr.json
```
