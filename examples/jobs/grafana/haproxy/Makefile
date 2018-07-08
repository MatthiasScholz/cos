category    := service
name        := grafanahaproxy
aws_reg     := eu-central-1
aws_profile := playground

docker_dir := .
################################################################################################################
# NOTE: The following lines can keep untouched. There is nothing more to configure the category and the name.  #
#################################################################################################################
# obtain aws account id
aws_aid  := $(shell aws sts get-caller-identity --output text --query 'Account' --profile $(aws_profile))

ecr_url  := $(aws_aid).dkr.ecr.$(aws_reg).amazonaws.com

# Create version tag from git commit message. Indicate if there are uncommited local changes.
date := $(shell date '+%Y-%m-%d_%H-%M-%S')
rev  := $(shell git rev-parse --short HEAD)
flag := $(shell git diff-index --quiet HEAD -- || echo "_dirty";)
tag  := $(date)_$(rev)$(flag)

# Create credentials for Docker for AWS ecr login
creds := $(shell aws ecr get-login --no-include-email --region $(aws_reg) --profile $(aws_profile))

dev: build finish
all: clean push finish


build: version delim
	@echo "[INFO] Building and tagging image"
	docker build -t $(category)/$(name) --build-arg VERSION=$(tag) .
	@docker tag $(category)/$(name):latest $(ecr_url)/$(category)/$(name):$(tag)

push: credentials build delim
	@echo "[INFO] Pushing image to AWS ECR"
	@docker push $(ecr_url)/$(category)/$(name):$(tag)

clean:
	@rm -f version


version: delim chgwork
	@echo "[INFO] Building version:"
	@echo $(tag) | tee version

credentials: delim
	@echo "[INFO] Login to AWS ECR"
	@$(creds)

chgwork: delim
	@echo "[INFO] Changing to work directory: $(docker_dir)"
	@cd $(docker_dir)

chgroot: delim
	@echo "[INFO] Changing to root directory"
	cd -

delim:
	@echo "------------------------------------------------------------------------------------------------"

finish:
	@echo "================================================================================================"
