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

nomad-consul-docker*.json:
	packer validate -var aws_region=$(aws_region) $@
	packer build -var aws_region=$(aws_region) $@

# NOTE AMIs are validated using goss, which needs to be supported with an additional plugin:
# -> https://github.com/YaleUniversity/packer-provisioner-goss
goss_provisioner_version := 2.0.0
goss_provisioser_archive := packer-provisioner-goss-v$(goss_provisioner_version)-darwin-amd64.tar.gz
goss_provisioner_source_path := https://github.com/YaleUniversity/packer-provisioner-goss/releases/download/v$(goss_provisioner_version)/$(goss_provisioser_archive)
goos_provisioner_binary := packer-provisioner-goss
goos_provisioner_install_path := ~/.packer.d/plugins/$(goos_provisioner_binary)
prepare:
	@echo "INFO :: Downloading goss packer plugin and install locally: $(goos_provisioner_install_path)"
	curl --location --remote-name $(goss_provisioner_source_path) --silent
	@tar -xvf $(goss_provisioser_archive)
	@rm -f $(goss_provisioser_archive)
	@chmod +x $(goos_provisioner_binary)
	mv $(goos_provisioner_binary) $(goos_provisioner_install_path)

uninstall:
	rm -f $(goos_provisioner_install_path)
