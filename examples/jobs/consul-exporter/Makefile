category = service
name     = prom-consul-exporter
tag      = 0.0.1


aws_reg  = us-east-1
ecr_url  = <aws_account_id>.dkr.ecr.$(aws_reg).amazonaws.com


all: credentials build tag push clean

credentials:
	aws ecr get-login --no-include-email --region $(aws_reg) > ecr_creds.sh
	chmod +x ecr_creds.sh
	./ecr_creds.sh

build:
	docker build -t $(category)/$(name) .

tag:
	docker tag $(category)/$(name):latest $(ecr_url)/$(category)/$(name):$(tag)

push:
	docker push $(ecr_url)/$(category)/$(name):$(tag)

clean:
	rm ecr_creds.sh
