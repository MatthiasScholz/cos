# Overview
#
# Providing some basic support to generate AMIs compatible with the COS setup.
#
# Usage:
# - Generation of default AMI with make ami.
#
# TODO: Export generated AMI-ID and make the usable in terraform.

# TODO: make this configurable, with default: AWS_DEFAULT_REGION
aws_region:=us-east-1

.PHONY: ami
.PHONY: nomad-consul-docker-ecr.json
.PHONY: nomad-consul-docker.json
.PHONY: nomad-consul-docker-ecr-cni.json

ami: nomad-consul-docker-ecr.json

nomad-consul-docker-ecr.json:
	packer build -var aws_region=$(aws_region) nomad-consul-docker-ecr.json

nomad-consul-docker.json:
	packer build -var aws_region=$(aws_region) nomad-consul-docker.json

nomad-consul-docker-ecr-cni.json:
	packer build -var aws_region=$(aws_region) nomad-consul-docker-ecr-cni.json
