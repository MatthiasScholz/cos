category = service
name     = kibana

################################################################################################################
# NOTE: The following lines can keep untouched. There is nothing more to configure the category and the name.  #
#################################################################################################################
aws_reg  := us-east-1
aws_aid  := <aws_account_id>
ecr_url  := $(aws_aid).dkr.ecr.$(aws_reg).amazonaws.com

# Create version tag from git commit message. Indicate if there are uncommited local changes.
date := $(shell date '+%Y-%m-%d_%H-%M-%S')
rev  := $(shell git rev-parse --short HEAD)
flag := $(shell git diff-index --quiet HEAD -- || echo "_dirty";)
tag  := $(date)$(rev)$(flag)

# Create credentials for Docker for AWS ecr login
creds := $(shell aws ecr get-login --no-include-email --region $(aws_reg))


all: credentials version build tag push clean finish

version:
	@echo "------------------------------------------------------------------------------------------------"
	@echo "[INFO] Building version:"
	@echo $(tag) | tee version

credentials:
	@echo "------------------------------------------------------------------------------------------------"
	@echo "[INFO] Login to AWS ECR"
	@$(creds)

build:
	@echo "------------------------------------------------------------------------------------------------"
	@echo "[INFO] Building image"
	docker build -t $(category)/$(name) --build-arg VERSION=$(tag) .

tag:
	@docker tag $(category)/$(name):latest $(ecr_url)/$(category)/$(name):$(tag)

push:
	@echo "------------------------------------------------------------------------------------------------"
	@echo "[INFO] Pushing image to AWS ECR"
	@docker push $(ecr_url)/$(category)/$(name):$(tag)

clean:
	@rm version

finish:
	@echo "================================================================================================"
